from django.urls import path
from . import views

# Fleet endpoints under /api/fleet/
urlpatterns = [
    path('', views.fleet_status, name='fleet_status'),
    path('status/', views.fleet_status, name='fleet_status_detailed'),
]