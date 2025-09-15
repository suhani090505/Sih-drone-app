from django.urls import path
from . import views

# Drone endpoints under /api/drones/
urlpatterns = [
    path('', views.list_drones, name='drone_list'),
    path('add/', views.add_drone, name='drone_add'),
    path('<uuid:drone_id>/', views.update_drone, name='drone_update'),
    path('<uuid:drone_id>/delete/', views.delete_drone, name='drone_delete'),
]