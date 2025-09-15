from django.contrib import admin
from .models import Drone

@admin.register(Drone)
class DroneAdmin(admin.ModelAdmin):
    list_display = ['id', 'status', 'urgency_level', 'assigned_pilot', 'created_at']
    list_filter = ['status', 'urgency_level', 'created_at']
    search_fields = ['id', 'assigned_pilot__username']
    readonly_fields = ['id', 'created_at', 'updated_at']