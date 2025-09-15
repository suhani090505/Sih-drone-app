from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count
from drone_app.models import Drone
from drone_app.serializers import DroneSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def fleet_status(request):
    # Get drones grouped by status
    active_drones = Drone.objects.filter(status='Active', is_deleted=False)
    maintenance_drones = Drone.objects.filter(status='In Maintenance', is_deleted=False)
    inactive_drones = Drone.objects.filter(status='Inactive', is_deleted=False)
    
    # Get counts
    status_counts = Drone.objects.filter(is_deleted=False).values('status').annotate(count=Count('status'))
    
    # Prepare response data
    fleet_data = {
        'summary': {
            'total_drones': Drone.objects.filter(is_deleted=False).count(),
            'active': active_drones.count(),
            'maintenance': maintenance_drones.count(),
            'inactive': inactive_drones.count(),
        },
        'drones_by_status': {
            'active': DroneSerializer(active_drones, many=True).data,
            'maintenance': DroneSerializer(maintenance_drones, many=True).data,
            'inactive': DroneSerializer(inactive_drones, many=True).data,
        },
        'status_distribution': {item['status']: item['count'] for item in status_counts}
    }
    
    return Response(fleet_data, status=status.HTTP_200_OK)