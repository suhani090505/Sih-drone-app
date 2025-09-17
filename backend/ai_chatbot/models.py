import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class ChatSession(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    title = models.CharField(max_length=200, default="New Chat")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"{self.user.username} - {self.title}"


class ChatMessage(models.Model):
    MESSAGE_TYPES = [
        ('user', 'User'),
        ('bot', 'Bot'),
        ('system', 'System'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='messages')
    message_type = models.CharField(max_length=10, choices=MESSAGE_TYPES)
    content = models.TextField()
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"{self.message_type}: {self.content[:50]}..."


class QuickAction(models.Model):
    ACTION_TYPES = [
        ('track_drone', 'Track Drone'),
        ('view_reports', 'View Reports'),
        ('check_weather', 'Check Weather'),
        ('fleet_status', 'Fleet Status'),
        ('create_order', 'Create Order'),
        ('inventory_check', 'Inventory Check'),
        ('emergency_alert', 'Emergency Alert'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    message = models.ForeignKey(ChatMessage, on_delete=models.CASCADE, related_name='quick_actions')
    action_type = models.CharField(max_length=20, choices=ACTION_TYPES)
    label = models.CharField(max_length=100)
    icon = models.CharField(max_length=50, default='help')
    data = models.JSONField(default=dict, blank=True)

    def __str__(self):
        return f"{self.label} - {self.action_type}"


class ChatAnalytics(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    query_type = models.CharField(max_length=100)
    response_time = models.FloatField()  # in seconds
    satisfaction_score = models.IntegerField(null=True, blank=True)  # 1-5 rating
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']