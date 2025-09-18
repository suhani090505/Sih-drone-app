from django.contrib import admin
from .models import FleetStatistics

@admin.register(FleetStatistics)
class FleetStatisticsAdmin(admin.ModelAdmin):
    list_display = ['month', 'number_of_active_drones', 'number_of_successful_deliveries', 
                   'number_of_unsuccessful_deliveries', 'average_response_time', 'updated_at']
    list_filter = ['month', 'created_at']
    readonly_fields = ['created_at', 'updated_at']
    ordering = ['-month']