from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count
from django.utils import timezone
from datetime import timedelta
from drone_app.models import Drone
from drone_app.serializers import DroneSerializer
from .models import FleetStatistics
from .serializers import FleetStatisticsSerializer, FleetStatisticsUpdateSerializer

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

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def fleet_statistics(request):
    """Get fleet statistics with optional month-wise filtering"""
    month_filter = request.GET.get('month')  # Format: YYYY-MM
    
    if month_filter:
        try:
            year, month = map(int, month_filter.split('-'))
            filter_date = datetime(year, month, 1).date()
            stats = FleetStatistics.objects.filter(month=filter_date)
        except (ValueError, TypeError):
            return Response(
                {'error': 'Invalid month format. Use YYYY-MM'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    else:
        # Update current month stats
        FleetStatistics.update_monthly_stats()
        stats = FleetStatistics.objects.all()[:12]  # Last 12 months
    
    serializer = FleetStatisticsSerializer(stats, many=True)
    
    # Calculate aggregated stats
    total_active = sum(stat.number_of_active_drones for stat in stats)
    total_successful = sum(stat.number_of_successful_deliveries for stat in stats)
    total_unsuccessful = sum(stat.number_of_unsuccessful_deliveries for stat in stats)
    avg_response_time = sum(stat.average_response_time for stat in stats) / len(stats) if stats else 0
    
    response_data = {
        'monthly_stats': serializer.data,
        'aggregated_stats': {
            'total_active_drones': total_active,
            'total_successful_deliveries': total_successful,
            'total_unsuccessful_deliveries': total_unsuccessful,
            'average_response_time': round(avg_response_time, 2),
            'success_rate': round(
                (total_successful / (total_successful + total_unsuccessful) * 100) 
                if (total_successful + total_unsuccessful) > 0 else 0, 2
            )
        }
    }
    
    return Response(response_data, status=status.HTTP_200_OK)

@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def manage_fleet_statistics(request):
    """Create or update fleet statistics"""
    month_param = request.data.get('month')
    
    if month_param:
        try:
            year, month = map(int, month_param.split('-'))
            month_date = timezone.datetime(year, month, 1).date()
        except (ValueError, TypeError):
            return Response(
                {'error': 'Invalid month format. Use YYYY-MM'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
    else:
        month_date = timezone.now().replace(day=1).date()
    
    try:
        stats = FleetStatistics.objects.get(month=month_date)
        serializer = FleetStatisticsUpdateSerializer(stats, data=request.data, partial=True)
    except FleetStatistics.DoesNotExist:
        data = request.data.copy()
        data['month'] = month_date
        serializer = FleetStatisticsSerializer(data=data)
    
    if serializer.is_valid():
        stats = serializer.save()
        return Response({
            'message': 'Fleet statistics updated successfully',
            'data': FleetStatisticsSerializer(stats).data
        }, status=status.HTTP_200_OK)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)