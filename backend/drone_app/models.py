import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Drone(models.Model):
    URGENCY_CHOICES = [
        ('Low', 'Low'),
        ('Medium', 'Medium'),
        ('High', 'High'),
        ('Critical', 'Critical'),
    ]
    
    STATUS_CHOICES = [
        ('Active', 'Active'),
        ('In Maintenance', 'In Maintenance'),
        ('Inactive', 'Inactive'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    location_latitude = models.DecimalField(max_digits=9, decimal_places=6)
    location_longitude = models.DecimalField(max_digits=9, decimal_places=6)
    package_details = models.JSONField(default=dict)
    urgency_level = models.CharField(max_length=10, choices=URGENCY_CHOICES, default='Low')
    assigned_pilot = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    additional_note = models.TextField(blank=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='Active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
    
    class Meta:
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Drone {str(self.id)[:8]} - {self.status}"