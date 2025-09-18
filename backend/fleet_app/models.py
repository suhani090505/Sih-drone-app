from django.db import models
from django.contrib.auth import get_user_model
from django.db.models import Avg, Count, Q
from django.utils import timezone
from django.utils.html import escape
from datetime import timedelta

User = get_user_model()

class FleetStatistics(models.Model):
    """Model to track fleet performance metrics"""
    
    # Core metrics
    number_of_active_drones = models.IntegerField(default=0)
    number_of_successful_deliveries = models.IntegerField(default=0)
    number_of_unsuccessful_deliveries = models.IntegerField(default=0)
    average_response_time = models.FloatField(default=0.0, help_text="Average response time in minutes")
    
    # Tracking fields
    month = models.DateField(help_text="Month for which these stats are recorded")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['month']
        ordering = ['-month']
    
    def __str__(self):
        return f"Fleet Stats for {escape(self.month.strftime('%B %Y'))}"
    
    @classmethod
    def get_current_month_stats(cls):
        """Get or create stats for current month"""
        from drone_app.models import Drone
        
        current_month = timezone.now().replace(day=1).date()
        stats, created = cls.objects.get_or_create(
            month=current_month,
            defaults={
                'number_of_active_drones': Drone.objects.filter(
                    status='Active', is_deleted=False
                ).count(),
                'number_of_successful_deliveries': 0,
                'number_of_unsuccessful_deliveries': 0,
                'average_response_time': 0.0
            }
        )
        return stats
    
    @classmethod
    def update_monthly_stats(cls, month_date=None):
        """Update statistics for a given month"""
        from drone_app.models import Drone
        
        if month_date is None:
            month_date = timezone.now().replace(day=1).date()
        
        # Calculate stats from drone data
        active_drones = Drone.objects.filter(
            status='Active', is_deleted=False
        ).count()
        
        # For now, use urgency level as proxy for delivery success
        # In a real system, you'd have delivery status tracking
        month_start = month_date
        month_end = (month_start.replace(month=month_start.month % 12 + 1) 
                    if month_start.month < 12 
                    else month_start.replace(year=month_start.year + 1, month=1))
        
        monthly_drones = Drone.objects.filter(
            created_at__date__gte=month_start,
            created_at__date__lt=month_end,
            is_deleted=False
        )
        
        successful = monthly_drones.filter(
            urgency_level__in=['Low', 'Medium']
        ).count()
        
        unsuccessful = monthly_drones.filter(
            urgency_level__in=['High', 'Critical']
        ).count()
        
        # Calculate average response time (mock calculation)
        avg_response = 15.5  # Default response time in minutes
        
        stats, created = cls.objects.update_or_create(
            month=month_date,
            defaults={
                'number_of_active_drones': active_drones,
                'number_of_successful_deliveries': successful,
                'number_of_unsuccessful_deliveries': unsuccessful,
                'average_response_time': avg_response
            }
        )
        return stats