import csv
from django.http import HttpResponse
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.db.models import Count, Q
from django.utils import timezone
from datetime import timedelta
from drone_app.models import Drone

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def reports_overview(request):
    total_drones = Drone.objects.filter(is_deleted=False).count()
    
    # Calculate missions completed (assuming status changes indicate missions)
    missions_completed = Drone.objects.filter(is_deleted=False).count()
    
    # Active vs maintenance ratio
    active_count = Drone.objects.filter(status='Active', is_deleted=False).count()
    maintenance_count = Drone.objects.filter(status='In Maintenance', is_deleted=False).count()
    inactive_count = Drone.objects.filter(status='Inactive', is_deleted=False).count()
    
    # Urgency level distribution
    urgency_distribution = Drone.objects.filter(is_deleted=False).values('urgency_level').annotate(count=Count('urgency_level'))
    
    # Last activity timestamps
    recent_activity = Drone.objects.filter(is_deleted=False).order_by('-updated_at')[:5]
    
    report_data = {
        'overview': {
            'total_drones_deployed': total_drones,
            'missions_completed': missions_completed,
            'active_vs_maintenance_ratio': {
                'active': active_count,
                'maintenance': maintenance_count,
                'inactive': inactive_count,
                'active_percentage': round((active_count / total_drones * 100) if total_drones > 0 else 0, 2),
                'maintenance_percentage': round((maintenance_count / total_drones * 100) if total_drones > 0 else 0, 2)
            },
            'urgency_level_distribution': {item['urgency_level']: item['count'] for item in urgency_distribution},
            'last_activity_timestamps': [
                {
                    'drone_id': str(drone.id),
                    'status': drone.status,
                    'last_updated': drone.updated_at,
                    'urgency_level': drone.urgency_level
                } for drone in recent_activity
            ]
        },
        'generated_at': timezone.now()
    }
    
    return Response(report_data, status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_report(request):
    format_type = request.GET.get('format', 'csv').lower()
    
    if format_type == 'csv':
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="drone_report.csv"'
        
        writer = csv.writer(response)
        writer.writerow(['Drone ID', 'Status', 'Urgency Level', 'Assigned Pilot', 'Location Lat', 'Location Lng', 'Created At', 'Updated At'])
        
        drones = Drone.objects.filter(is_deleted=False)
        for drone in drones:
            writer.writerow([
                str(drone.id),
                drone.status,
                drone.urgency_level,
                drone.assigned_pilot.username if drone.assigned_pilot else 'Unassigned',
                drone.location_latitude,
                drone.location_longitude,
                drone.created_at,
                drone.updated_at
            ])
        
        return response
    
    return Response({'error': 'Unsupported format'}, status=status.HTTP_400_BAD_REQUEST)