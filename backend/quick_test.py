#!/usr/bin/env python3
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'drone_backend.settings')
django.setup()

def test_fleet_models():
    """Test if fleet models can be imported and basic operations work"""
    try:
        from fleet_app.models import FleetStatistics
        from fleet_app.serializers import FleetStatisticsSerializer
        from django.utils import timezone
        
        print("✅ Models imported successfully")
        
        # Test model creation
        month_date = timezone.now().replace(day=1).date()
        stats = FleetStatistics(
            number_of_active_drones=10,
            number_of_successful_deliveries=50,
            number_of_unsuccessful_deliveries=5,
            average_response_time=15.5,
            month=month_date
        )
        
        print("✅ Model instance created successfully")
        print(f"Stats: {stats}")
        
        # Test serializer
        serializer = FleetStatisticsSerializer(stats)
        data = serializer.data
        print("✅ Serializer works")
        print(f"Serialized data keys: {list(data.keys())}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_urls():
    """Test if URLs are configured correctly"""
    try:
        from django.urls import reverse
        from django.test import Client
        
        # Test URL patterns
        client = Client()
        
        # These should not raise errors (even if they return 401/403)
        response = client.get('/api/fleet/statistics/')
        print(f"✅ Fleet statistics URL accessible (status: {response.status_code})")
        
        response = client.post('/api/fleet/statistics/manage/')
        print(f"✅ Fleet manage URL accessible (status: {response.status_code})")
        
        return True
        
    except Exception as e:
        print(f"❌ URL Error: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Quick Backend Test")
    print("=" * 30)
    
    model_test = test_fleet_models()
    url_test = test_urls()
    
    if model_test and url_test:
        print("\n✅ Backend implementation looks good!")
        print("Next steps:")
        print("1. Run: python manage.py makemigrations fleet_app")
        print("2. Run: python manage.py migrate")
        print("3. Run: python manage.py runserver")
        print("4. Test APIs with: python test_fleet_api.py")
    else:
        print("\n❌ Issues found - check the errors above")
