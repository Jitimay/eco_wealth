#!/usr/bin/env python3
"""
Train EchoWealth poverty prediction model.
Optimized for Arm NPU deployment with TensorFlow Lite.
"""

import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, classification_report
import json

def create_model(input_shape):
    """Create optimized LSTM + Transformer model for Arm NPU."""
    
    # Input layer
    inputs = keras.Input(shape=input_shape, name='features')
    
    # Reshape for LSTM (add time dimension)
    x = tf.expand_dims(inputs, axis=1)
    
    # LSTM layer (optimized for mobile)
    x = keras.layers.LSTM(24, return_sequences=True, name='lstm')(x)
    x = keras.layers.Dropout(0.2)(x)
    
    # Transformer encoder (lightweight)
    attention = keras.layers.MultiHeadAttention(
        num_heads=2, 
        key_dim=16,
        name='attention'
    )(x, x)
    x = keras.layers.Add()([x, attention])
    x = keras.layers.LayerNormalization()(x)
    
    # Global pooling and dense layers
    x = keras.layers.GlobalAveragePooling1D()(x)
    x = keras.layers.Dense(32, activation='relu', name='dense1')(x)
    x = keras.layers.Dropout(0.3)(x)
    x = keras.layers.Dense(16, activation='relu', name='dense2')(x)
    
    # Output layer (sigmoid for probability)
    outputs = keras.layers.Dense(1, activation='sigmoid', name='risk_score')(x)
    
    model = keras.Model(inputs=inputs, outputs=outputs, name='echo_wealth_model')
    
    return model

def train_model():
    """Train the poverty prediction model."""
    
    print("Loading training data...")
    X = np.load('training_features.npy')
    y = np.load('training_labels.npy')
    
    print(f"Dataset shape: {X.shape}, Labels shape: {y.shape}")
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=(y > 0.5).astype(int)
    )
    
    print(f"Training set: {X_train.shape[0]} samples")
    print(f"Test set: {X_test.shape[0]} samples")
    
    # Create model
    model = create_model(input_shape=(X.shape[1],))
    
    # Compile with appropriate loss for regression
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='binary_crossentropy',  # Treat as binary classification
        metrics=['mae', 'mse']
    )
    
    print("\nModel architecture:")
    model.summary()
    
    # Callbacks for training
    callbacks = [
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-6
        )
    ]
    
    # Train model
    print("\nTraining model...")
    history = model.fit(
        X_train, y_train,
        validation_data=(X_test, y_test),
        epochs=100,
        batch_size=32,
        callbacks=callbacks,
        verbose=1
    )
    
    # Evaluate model
    print("\nEvaluating model...")
    y_pred = model.predict(X_test)
    
    # Calculate metrics
    auc_score = roc_auc_score(y_test > 0.5, y_pred)
    mae = np.mean(np.abs(y_test - y_pred.flatten()))
    
    print(f"AUC Score: {auc_score:.4f}")
    print(f"Mean Absolute Error: {mae:.4f}")
    
    # Classification report (treating as binary classification)
    y_pred_binary = (y_pred > 0.5).astype(int)
    y_test_binary = (y_test > 0.5).astype(int)
    
    print("\nClassification Report:")
    print(classification_report(y_test_binary, y_pred_binary, 
                              target_names=['Low Risk', 'High Risk']))
    
    # Save model
    model.save('echo_wealth_model.h5')
    
    # Save training metadata
    metadata = {
        'model_type': 'LSTM + Transformer',
        'input_shape': X.shape[1],
        'training_samples': len(X_train),
        'test_samples': len(X_test),
        'auc_score': float(auc_score),
        'mae': float(mae),
        'final_loss': float(history.history['loss'][-1]),
        'final_val_loss': float(history.history['val_loss'][-1]),
        'epochs_trained': len(history.history['loss']),
        'model_size_mb': 1.2,  # Estimated after quantization
        'target_inference_ms': 50,
        'target_power_w': 0.03
    }
    
    with open('model_metadata.json', 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"\nModel saved as echo_wealth_model.h5")
    print(f"Metadata saved as model_metadata.json")
    
    return model, metadata

def main():
    """Main training pipeline."""
    try:
        model, metadata = train_model()
        
        print("\n" + "="*50)
        print("TRAINING COMPLETE")
        print("="*50)
        print(f"AUC Score: {metadata['auc_score']:.4f} (Target: >0.75)")
        print(f"MAE: {metadata['mae']:.4f}")
        print(f"Model ready for TensorFlow Lite conversion")
        print("\nNext steps:")
        print("1. Run export_tflite.py to convert to TFLite")
        print("2. Copy echo_wealth.tflite to Flutter assets/models/")
        print("3. Test on Android device")
        
    except FileNotFoundError:
        print("Error: Training data not found!")
        print("Please run generate_synthetic_data.py first")
    except Exception as e:
        print(f"Training failed: {e}")

if __name__ == "__main__":
    main()
