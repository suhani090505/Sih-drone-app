from rest_framework import serializers
from .models import FleetStatistics

class FleetStatisticsSerializer(serializers.ModelSerializer):
    month_display = serializers.CharField(source='month', read_only=True)
    
    class Meta:
        model = FleetStatistics
        fields = [
            'id', 'number_of_active_drones', 'number_of_successful_deliveries',
            'number_of_unsuccessful_deliveries', 'average_response_time',
            'month', 'month_display', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['month_display'] = instance.month.strftime('%B %Y')
        return data

class FleetStatisticsUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = FleetStatistics
        fields = [
            'number_of_active_drones', 'number_of_successful_deliveries',
            'number_of_unsuccessful_deliveries', 'average_response_time'
        ]