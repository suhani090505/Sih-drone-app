from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count
from drone_app.models import Drone
from drone_app.serializers import DroneSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_summary(request):
    """
    Dashboard endpoint that combines drone, fleet, and report statistics
    for Flutter app main screen
    """
    
    # Get drone statistics
    total_drones = Drone.objects.filter(is_deleted=False).count()
    active_drones = Drone.objects.filter(status='Active', is_deleted=False).count()
    maintenance_drones = Drone.objects.filter(status='In Maintenance', is_deleted=False).count()
    inactive_drones = Drone.objects.filter(status='Inactive', is_deleted=False).count()
    
    # Get urgency level distribution
    urgency_stats = Drone.objects.filter(is_deleted=False).values('urgency_level').annotate(count=Count('urgency_level'))
    urgency_distribution = {item['urgency_level']: item['count'] for item in urgency_stats}
    
    # Get recent drones (last 5 updated)
    recent_drones = Drone.objects.filter(is_deleted=False).order_by('-updated_at')[:5]
    
    # Calculate fleet health percentage
    fleet_health = round((active_drones / total_drones * 100) if total_drones > 0 else 0, 1)
    
    dashboard_data = {
        'user': {
            'id': request.user.id,
            'username': request.user.username,
            'email': request.user.email
        },
        'fleet_overview': {
            'total_drones': total_drones,
            'active': active_drones,
            'maintenance': maintenance_drones,
            'inactive': inactive_drones,
            'fleet_health_percentage': fleet_health
        },
        'urgency_distribution': urgency_distribution,
        'recent_activity': DroneSerializer(recent_drones, many=True).data,
        'quick_stats': {
            'missions_completed': total_drones,  # Placeholder - can be enhanced
            'active_missions': active_drones,
            'maintenance_required': maintenance_drones,
            'critical_alerts': Drone.objects.filter(urgency_level='Critical', is_deleted=False).count()
        },
        'status': 'success',
        'message': 'Dashboard data loaded successfully'
    }
    
    return Response(dashboard_data, status=status.HTTP_200_OK)