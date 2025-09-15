from rest_framework import serializers
from .models import Drone
from django.contrib.auth import get_user_model

User = get_user_model()

class DroneSerializer(serializers.ModelSerializer):
    assigned_pilot_name = serializers.CharField(source='assigned_pilot.username', read_only=True)
    location = serializers.SerializerMethodField()
    
    class Meta:
        model = Drone
        fields = [
            'id', 'location', 'location_latitude', 'location_longitude',
            'package_details', 'urgency_level', 'assigned_pilot',
            'assigned_pilot_name', 'additional_note', 'status',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_location(self, obj):
        return {
            'latitude': float(obj.location_latitude),
            'longitude': float(obj.location_longitude)
        }
    
    def validate_assigned_pilot(self, value):
        if value and not User.objects.filter(id=value.id).exists():
            raise serializers.ValidationError("Assigned pilot does not exist")
        return value