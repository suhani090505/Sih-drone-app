from django.contrib import admin
from .models import ChatSession, ChatMessage, QuickAction, ChatAnalytics


@admin.register(ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'title', 'created_at', 'updated_at', 'is_active']
    list_filter = ['is_active', 'created_at', 'updated_at']
    search_fields = ['user__username', 'user__email', 'title']
    readonly_fields = ['id', 'created_at', 'updated_at']
    ordering = ['-updated_at']


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'session', 'message_type', 'content_preview', 'created_at']
    list_filter = ['message_type', 'created_at']
    search_fields = ['content', 'session__user__username']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']
    
    def content_preview(self, obj):
        return obj.content[:50] + "..." if len(obj.content) > 50 else obj.content
    content_preview.short_description = 'Content Preview'


@admin.register(QuickAction)
class QuickActionAdmin(admin.ModelAdmin):
    list_display = ['id', 'message', 'action_type', 'label', 'icon']
    list_filter = ['action_type']
    search_fields = ['label', 'action_type']
    readonly_fields = ['id']


@admin.register(ChatAnalytics)
class ChatAnalyticsAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'query_type', 'response_time', 'satisfaction_score', 'created_at']
    list_filter = ['query_type', 'satisfaction_score', 'created_at']
    search_fields = ['user__username', 'query_type']
    readonly_fields = ['id', 'created_at']
    ordering = ['-created_at']