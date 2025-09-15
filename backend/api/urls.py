from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

# Create router for viewsets
router = DefaultRouter()

urlpatterns = [
    # Include router URLs
    path('', include(router.urls)),
    
    # Authentication endpoints
    path('auth/', include('auth_app.urls')),
    
    # Drone management endpoints
    path('drones/', include('drone_app.urls')),
    
    # Fleet management endpoints
    path('fleet/', include('fleet_app.urls')),
    
    # Reports endpoints
    path('reports/', include('report_app.urls')),
    
    # Dashboard endpoint (combines all stats)
    path('dashboard/', views.dashboard_summary, name='dashboard_summary'),
]