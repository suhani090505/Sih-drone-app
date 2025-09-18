#!/usr/bin/env python3
"""
Test script for Fleet Statistics API endpoints
"""

import requests
import json
from datetime import datetime

BASE_URL = "http://127.0.0.1:8000/api"

def test_fleet_statistics():
    """Test the fleet statistics endpoints"""
    
    print("🧪 Testing Fleet Statistics API...")
    
    # Test GET fleet statistics
    print("\n1. Testing GET /api/fleet/statistics/")
    try:
        response = requests.get(f"{BASE_URL}/fleet/statistics/")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ GET statistics successful")
            print(f"Monthly stats count: {len(data.get('monthly_stats', []))}")
            print(f"Aggregated stats: {data.get('aggregated_stats', {})}")
        else:
            print(f"❌ GET statistics failed: {response.text}")
    except Exception as e:
        print(f"❌ Error testing GET statistics: {e}")
    
    # Test GET with month filter
    print("\n2. Testing GET /api/fleet/statistics/ with month filter")
    current_month = datetime.now().strftime("%Y-%m")
    try:
        response = requests.get(f"{BASE_URL}/fleet/statistics/?month={current_month}")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ GET statistics with month filter successful")
            print(f"Filtered stats: {data}")
        else:
            print(f"❌ GET statistics with filter failed: {response.text}")
    except Exception as e:
        print(f"❌ Error testing GET statistics with filter: {e}")
    
    # Test POST fleet statistics
    print("\n3. Testing POST /api/fleet/statistics/manage/")
    test_data = {
        "number_of_active_drones": 15,
        "number_of_successful_deliveries": 120,
        "number_of_unsuccessful_deliveries": 8,
        "average_response_time": 12.5,
        "month": current_month
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/fleet/statistics/manage/",
            json=test_data,
            headers={"Content-Type": "application/json"}
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ POST statistics successful")
            print(f"Response: {data}")
        else:
            print(f"❌ POST statistics failed: {response.text}")
    except Exception as e:
        print(f"❌ Error testing POST statistics: {e}")
    
    # Test existing fleet status endpoint
    print("\n4. Testing existing GET /api/fleet/")
    try:
        response = requests.get(f"{BASE_URL}/fleet/")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print("✅ GET fleet status successful")
            print(f"Summary: {data.get('summary', {})}")
        else:
            print(f"❌ GET fleet status failed: {response.text}")
    except Exception as e:
        print(f"❌ Error testing GET fleet status: {e}")

if __name__ == "__main__":
    print("🚀 Fleet Statistics API Test Suite")
    print("=" * 50)
    test_fleet_statistics()
    print("\n" + "=" * 50)
    print("✨ Test completed!")