#!/usr/bin/env python3
"""
Create a mock TensorFlow Lite model for development and testing.
This allows the Flutter app to run without the full ML pipeline.
"""

import tensorflow as tf
import numpy as np
import os

def create_mock_model():
    """Create a simple mock model that mimics the real poverty prediction model."""
    
    # Create a simple model with the same input/output signature
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(21,), name='features'),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dense(8, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid', name='risk_score')
    ])
    
    # Compile the model
    model.compile(optimizer='adam', loss='binary_crossentropy')
    
    # Create some dummy training data
    X_dummy = np.random.randn(100, 21).astype(np.float32)
    y_dummy = np.random.rand(100, 1).astype(np.float32)
    
    # Train for a few epochs to initialize weights
    model.fit(X_dummy, y_dummy, epochs=5, verbose=0)
    
    print("Mock model created and trained")
    return model

def convert_to_tflite(model):
    """Convert the mock model to TensorFlow Lite."""
    
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    tflite_model = converter.convert()
    
    # Save to assets directory
    assets_dir = 'assets/models'
    os.makedirs(assets_dir, exist_ok=True)
    
    model_path = os.path.join(assets_dir, 'echo_wealth.tflite')
    with open(model_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"Mock TFLite model saved to {model_path}")
    print(f"Model size: {len(tflite_model) / 1024:.1f} KB")
    
    return model_path

def verify_mock_model(model_path):
    """Verify the mock model works."""
    
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Test with random input
    test_input = np.random.randn(1, 21).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], test_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"Test inference: Input shape {test_input.shape} -> Output {output[0][0]:.3f}")
    print("Mock model verification successful!")

def main():
    print("Creating mock TensorFlow Lite model for EchoWealth...")
    
    # Create and convert model
    model = create_mock_model()
    model_path = convert_to_tflite(model)
    verify_mock_model(model_path)
    
    print("\nMock model ready for Flutter development!")
    print("The app can now run without the full ML training pipeline.")

if __name__ == "__main__":
    main()
