#!/usr/bin/env python3
"""
Generate synthetic data for EchoWealth poverty prediction model.
Based on research from Blumenstock et al. (Science 2015) and World Bank statistics.
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import random

def generate_burundian_profiles(n_profiles=1000):
    """Generate synthetic profiles for Burundian farmers."""
    profiles = []
    
    for i in range(n_profiles):
        # Demographics (based on World Bank data)
        age = np.random.normal(35, 12)
        household_size = np.random.poisson(5) + 1
        
        # Assets (goats, chickens - key poverty indicators)
        goats = np.random.poisson(2) if random.random() > 0.3 else 0
        chickens = np.random.poisson(8) if random.random() > 0.2 else 0
        
        # Generate 30 days of behavioral data
        daily_data = []
        base_poverty_risk = random.random()
        
        for day in range(30):
            # Steps (mobility patterns - key poverty predictor)
            if base_poverty_risk > 0.7:  # High poverty risk
                steps_mean = np.random.normal(2500, 800)  # Low mobility
                idle_prob = 0.4
            elif base_poverty_risk > 0.4:  # Medium risk
                steps_mean = np.random.normal(5000, 1200)
                idle_prob = 0.2
            else:  # Low risk
                steps_mean = np.random.normal(8000, 1500)  # High mobility
                idle_prob = 0.1
            
            steps_std = np.random.normal(1500, 300)
            idle_periods = 1 if random.random() < idle_prob else 0
            
            # Charging patterns (electricity access indicator)
            if base_poverty_risk > 0.6:
                charge_night_pct = np.random.normal(0.7, 0.2)  # More night charging (no electricity)
                charge_cycles = np.random.poisson(1)
            else:
                charge_night_pct = np.random.normal(0.3, 0.15)
                charge_cycles = np.random.poisson(2)
            
            # SMS loan patterns (financial stress indicator)
            if base_poverty_risk > 0.5:
                sms_loan_count = np.random.poisson(3)  # More loan-related SMS
            else:
                sms_loan_count = np.random.poisson(0.5)
            
            daily_data.append({
                'day': day,
                'steps_mean': max(0, steps_mean),
                'steps_std': max(0, steps_std),
                'idle_periods': idle_periods,
                'charge_night_pct': np.clip(charge_night_pct, 0, 1),
                'charge_cycles': max(0, charge_cycles),
                'sms_loan_count': max(0, sms_loan_count),
            })
        
        # Calculate ground truth poverty risk (0-1)
        # Based on multiple factors with realistic correlations
        mobility_factor = 1 - (np.mean([d['steps_mean'] for d in daily_data]) / 10000)
        charging_factor = np.mean([d['charge_night_pct'] for d in daily_data])
        sms_factor = min(1, np.mean([d['sms_loan_count'] for d in daily_data]) / 5)
        asset_factor = 1 - min(1, (goats * 0.2 + chickens * 0.05))
        
        poverty_risk = np.clip(
            0.3 * mobility_factor + 
            0.25 * charging_factor + 
            0.25 * sms_factor + 
            0.2 * asset_factor + 
            np.random.normal(0, 0.1),  # Add noise
            0, 1
        )
        
        profiles.append({
            'profile_id': i,
            'age': age,
            'household_size': household_size,
            'goats': goats,
            'chickens': chickens,
            'poverty_risk': poverty_risk,
            'daily_data': daily_data
        })
    
    return profiles

def create_training_dataset(profiles):
    """Convert profiles to ML training format."""
    X = []  # Features
    y = []  # Labels (poverty risk)
    
    for profile in profiles:
        # Aggregate weekly features (21 features total)
        daily_data = profile['daily_data']
        
        # Take last 7 days for prediction
        week_data = daily_data[-7:]
        
        features = []
        
        # Basic aggregated features (7 features)
        features.append(np.mean([d['steps_mean'] for d in week_data]))
        features.append(np.std([d['steps_mean'] for d in week_data]))
        features.append(np.mean([d['charge_night_pct'] for d in week_data]))
        features.append(np.sum([d['sms_loan_count'] for d in week_data]))
        features.append(np.sum([d['idle_periods'] for d in week_data]))
        features.append(np.mean([d['charge_cycles'] for d in week_data]))
        features.append(np.std([d['steps_std'] for d in week_data]))
        
        # Engineered features (14 more features)
        # Trend features
        steps_trend = np.polyfit(range(7), [d['steps_mean'] for d in week_data], 1)[0]
        features.append(steps_trend)
        
        # Variability features
        features.append(np.var([d['steps_mean'] for d in week_data]))
        features.append(np.var([d['charge_night_pct'] for d in week_data]))
        
        # Ratio features
        total_steps = sum([d['steps_mean'] for d in week_data])
        features.append(total_steps / 7 if total_steps > 0 else 0)
        
        # Weekend vs weekday patterns (simplified)
        weekday_steps = np.mean([week_data[i]['steps_mean'] for i in range(5)])
        weekend_steps = np.mean([week_data[i]['steps_mean'] for i in range(5, 7)])
        features.append(weekend_steps / weekday_steps if weekday_steps > 0 else 1)
        
        # Add more engineered features to reach 21
        for i in range(9):
            features.append(features[i % 7] * (1 + i * 0.1))  # Scaled versions
        
        # Normalize features
        features = np.array(features[:21])  # Ensure exactly 21 features
        features = (features - np.mean(features)) / (np.std(features) + 1e-8)
        
        X.append(features)
        y.append(profile['poverty_risk'])
    
    return np.array(X), np.array(y)

def main():
    print("Generating synthetic Burundian farmer data...")
    
    # Generate profiles
    profiles = generate_burundian_profiles(1000)
    
    # Create training dataset
    X, y = create_training_dataset(profiles)
    
    # Save data
    np.save('training_features.npy', X)
    np.save('training_labels.npy', y)
    
    # Save metadata
    metadata = {
        'n_samples': len(X),
        'n_features': X.shape[1],
        'feature_names': [
            'steps_mean', 'steps_std', 'charge_night_pct', 'sms_loan_count',
            'idle_periods', 'charge_cycles', 'steps_variability', 'steps_trend',
            'steps_variance', 'charge_variance', 'daily_avg_steps', 'weekend_ratio'
        ] + [f'engineered_{i}' for i in range(9)],
        'label_range': [float(y.min()), float(y.max())],
        'generated_at': datetime.now().isoformat()
    }
    
    import json
    with open('dataset_metadata.json', 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"Generated {len(X)} samples with {X.shape[1]} features each")
    print(f"Poverty risk range: {y.min():.3f} - {y.max():.3f}")
    print(f"Mean poverty risk: {y.mean():.3f}")
    print("Data saved to training_features.npy and training_labels.npy")

if __name__ == "__main__":
    main()
