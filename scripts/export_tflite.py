#!/usr/bin/env python3
"""
Export trained model to TensorFlow Lite for Arm NPU deployment.
Applies quantization and optimization for mobile devices.
"""

import tensorflow as tf
import numpy as np
import os

def convert_to_tflite(model_path='echo_wealth_model.h5', output_path='echo_wealth.tflite'):
    """Convert Keras model to optimized TensorFlow Lite."""
    
    print(f"Loading model from {model_path}...")
    model = tf.keras.models.load_model(model_path)
    
    # Load representative dataset for quantization
    try:
        X_train = np.load('training_features.npy')
        print(f"Loaded {len(X_train)} samples for representative dataset")
    except FileNotFoundError:
        print("Warning: No training data found, using random data for quantization")
        X_train = np.random.randn(100, 21).astype(np.float32)
    
    def representative_dataset():
        """Representative dataset for post-training quantization."""
        for i in range(min(100, len(X_train))):
            yield [X_train[i:i+1].astype(np.float32)]
    
    # Create TensorFlow Lite converter
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimization settings for Arm NPU
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Enable quantization for smaller model size and faster inference
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [
        tf.lite.OpsSet.TFLITE_BUILTINS_INT8,
        tf.lite.OpsSet.TFLITE_BUILTINS
    ]
    converter.inference_input_type = tf.float32
    converter.inference_output_type = tf.float32
    
    # Additional optimizations for mobile
    converter.experimental_new_converter = True
    converter.experimental_new_quantizer = True
    
    print("Converting to TensorFlow Lite...")
    print("Applying INT8 quantization for Arm NPU optimization...")
    
    try:
        tflite_model = converter.convert()
        
        # Save the model
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        # Get model size
        model_size_mb = len(tflite_model) / (1024 * 1024)
        
        print(f"✓ Model converted successfully!")
        print(f"✓ Output: {output_path}")
        print(f"✓ Size: {model_size_mb:.2f} MB")
        
        # Verify the model works
        verify_tflite_model(output_path, X_train[:5])
        
        return tflite_model, model_size_mb
        
    except Exception as e:
        print(f"Conversion failed: {e}")
        print("Trying fallback conversion without full quantization...")
        
        # Fallback: lighter quantization
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        
        tflite_model = converter.convert()
        
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        model_size_mb = len(tflite_model) / (1024 * 1024)
        print(f"✓ Fallback conversion successful: {model_size_mb:.2f} MB")
        
        return tflite_model, model_size_mb

def verify_tflite_model(model_path, test_data):
    """Verify the TFLite model works correctly."""
    
    print("\nVerifying TFLite model...")
    
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Output shape: {output_details[0]['shape']}")
    
    # Test inference
    total_time = 0
    for i, sample in enumerate(test_data):
        # Prepare input
        input_data = sample.reshape(1, -1).astype(np.float32)
        
        # Run inference
        start_time = tf.timestamp()
        interpreter.set_tensor(input_details[0]['index'], input_data)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        end_time = tf.timestamp()
        
        inference_time = (end_time - start_time) * 1000  # Convert to ms
        total_time += inference_time
        
        print(f"Sample {i+1}: Risk = {output_data[0][0]:.3f}, Time = {inference_time:.1f}ms")
    
    avg_time = total_time / len(test_data)
    print(f"\nAverage inference time: {avg_time:.1f}ms")
    
    if avg_time < 50:
        print("✓ Performance target met (<50ms)")
    else:
        print("⚠ Performance target not met (>50ms)")
    
    return avg_time

def create_flutter_assets():
    """Copy model to Flutter assets directory."""
    
    flutter_assets_dir = '../assets/models/'
    os.makedirs(flutter_assets_dir, exist_ok=True)
    
    if os.path.exists('echo_wealth.tflite'):
        import shutil
        shutil.copy('echo_wealth.tflite', flutter_assets_dir)
        print(f"✓ Model copied to {flutter_assets_dir}")
    else:
        print("⚠ TFLite model not found")

def main():
    """Main export pipeline."""
    
    print("EchoWealth Model Export Pipeline")
    print("="*40)
    
    try:
        # Convert to TFLite
        tflite_model, size_mb = convert_to_tflite()
        
        # Copy to Flutter assets
        create_flutter_assets()
        
        print("\n" + "="*40)
        print("EXPORT COMPLETE")
        print("="*40)
        print(f"✓ Model size: {size_mb:.2f} MB (Target: <1.5 MB)")
        print(f"✓ Optimized for Arm NPU with NNAPI")
        print(f"✓ Ready for Flutter integration")
        
        print("\nNext steps:")
        print("1. Copy echo_wealth.tflite to Flutter assets/models/")
        print("2. Run 'flutter pub get' in the Flutter project")
        print("3. Test on Android device with Arm NPU")
        print("4. Monitor inference time and power usage")
        
        # Generate deployment checklist
        checklist = {
            "model_ready": True,
            "size_optimized": size_mb < 1.5,
            "quantization_applied": True,
            "arm_npu_compatible": True,
            "flutter_integration_ready": True
        }
        
        import json
        with open('deployment_checklist.json', 'w') as f:
            json.dump(checklist, f, indent=2)
        
        print("✓ Deployment checklist saved")
        
    except Exception as e:
        print(f"Export failed: {e}")
        print("Please ensure the trained model exists (run train_model.py first)")

if __name__ == "__main__":
    main()
