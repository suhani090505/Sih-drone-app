from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Drone
from .serializers import DroneSerializer

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_drone(request):
    serializer = DroneSerializer(data=request.data)
    if serializer.is_valid():
        drone = serializer.save()
        return Response({
            'message': 'Drone added successfully',
            'drone': DroneSerializer(drone).data
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_drones(request):
    urgency = request.GET.get('urgency')
    drone_status = request.GET.get('status')
    
    drones = Drone.objects.filter(is_deleted=False)
    
    if urgency:
        drones = drones.filter(urgency_level=urgency)
    if drone_status:
        drones = drones.filter(status=drone_status)
    
    serializer = DroneSerializer(drones, many=True)
    return Response({
        'count': drones.count(),
        'drones': serializer.data
    }, status=status.HTTP_200_OK)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_drone(request, drone_id):
    drone = get_object_or_404(Drone, id=drone_id, is_deleted=False)
    serializer = DroneSerializer(drone, data=request.data, partial=True)
    
    if serializer.is_valid():
        drone = serializer.save()
        return Response({
            'message': 'Drone updated successfully',
            'drone': DroneSerializer(drone).data
        }, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_drone(request, drone_id):
    drone = get_object_or_404(Drone, id=drone_id, is_deleted=False)
    drone.is_deleted = True
    drone.save()
    
    return Response({
        'message': 'Drone deleted successfully'
    }, status=status.HTTP_200_OK)