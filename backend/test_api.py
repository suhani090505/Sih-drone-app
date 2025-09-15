import requests
import json

BASE_URL = "http://127.0.0.1:8000"
API_BASE_URL = "http://127.0.0.1:8000/api"

def test_health_check():
    print("Testing Health Check...")
    response = requests.get(f"{BASE_URL}/")
    print(f"Health Check: {response.status_code} - {response.json()}")
    return response.status_code == 200

def test_auth_endpoints():
    print("\nTesting Authentication Endpoints...")
    
    # Test Register
    register_data = {
        "username": "testuser",
        "email": "test@example.com",
        "password": "testpass123"
    }
    
    response = requests.post(f"{API_BASE_URL}/auth/register/", json=register_data)
    print(f"Register: {response.status_code} - {response.json()}")
    
    # Test Login
    login_data = {
        "email": "test@example.com",
        "password": "testpass123"
    }
    
    response = requests.post(f"{API_BASE_URL}/auth/login/", json=login_data)
    print(f"Login: {response.status_code} - {response.json()}")
    
    if response.status_code == 200 and response.json().get('success'):
        return response.json()['tokens']['access']
    return None

def test_drone_endpoints(token):
    print("\nTesting Drone Endpoints...")
    headers = {"Authorization": f"Bearer {token}"}
    
    # Test Add Drone
    drone_data = {
        "location_latitude": 28.6139,
        "location_longitude": 77.2090,
        "package_details": {"weight": "2kg", "type": "medical"},
        "urgency_level": "High",
        "additional_note": "Emergency medical supply"
    }
    
    response = requests.post(f"{API_BASE_URL}/drones/add/", json=drone_data, headers=headers)
    print(f"Add Drone: {response.status_code} - {response.json()}")
    
    # Test List Drones
    response = requests.get(f"{API_BASE_URL}/drones/", headers=headers)
    print(f"List Drones: {response.status_code} - {response.json()}")
    
    return response.json() if response.status_code == 200 else None

def test_fleet_endpoints(token):
    print("\nTesting Fleet Endpoints...")
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(f"{API_BASE_URL}/fleet/", headers=headers)
    print(f"Fleet Status: {response.status_code} - {response.json()}")
    return response.json() if response.status_code == 200 else None

def test_report_endpoints(token):
    print("\nTesting Report Endpoints...")
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(f"{API_BASE_URL}/reports/overview/", headers=headers)
    print(f"Reports Overview: {response.status_code} - {response.json()}")
    return response.json() if response.status_code == 200 else None

def test_dashboard_endpoint(token):
    print("\nTesting Dashboard Endpoint...")
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.get(f"{API_BASE_URL}/dashboard/", headers=headers)
    print(f"Dashboard: {response.status_code} - {response.json()}")
    return response.json() if response.status_code == 200 else None

if __name__ == "__main__":
    print("Starting API Tests...")
    print("=" * 50)
    
    # Test health check first
    if not test_health_check():
        print("Health check failed! Make sure server is running.")
        exit(1)
    
    # Test authentication and get token
    token = test_auth_endpoints()
    
    if token:
        print(f"\nAuthentication successful! Token: {token[:20]}...")
        
        # Test other endpoints with token
        drone_data = test_drone_endpoints(token)
        fleet_data = test_fleet_endpoints(token)
        report_data = test_report_endpoints(token)
        dashboard_data = test_dashboard_endpoint(token)
        
        print("\n" + "=" * 50)
        print("API INTEGRATION SUMMARY:")
        print(f"✅ Health Check: Working")
        print(f"✅ Authentication: Working")
        print(f"✅ Drones API: {'Working' if drone_data else 'Failed'}")
        print(f"✅ Fleet API: {'Working' if fleet_data else 'Failed'}")
        print(f"✅ Reports API: {'Working' if report_data else 'Failed'}")
        print(f"✅ Dashboard API: {'Working' if dashboard_data else 'Failed'}")
        
    else:
        print("Authentication failed, skipping other tests")
    
    print("\n" + "=" * 50)
    print("API Tests Completed!")
    print("\nFlutter Integration URLs:")
    print(f"Base URL: {API_BASE_URL}")
    print(f"Auth: {API_BASE_URL}/auth/")
    print(f"Drones: {API_BASE_URL}/drones/")
    print(f"Fleet: {API_BASE_URL}/fleet/")
    print(f"Reports: {API_BASE_URL}/reports/")
    print(f"Dashboard: {API_BASE_URL}/dashboard/")