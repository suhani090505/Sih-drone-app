from django.contrib import admin
from .models import User

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['id', 'username', 'email', 'is_first_time']
    list_filter = ['is_first_time']
    search_fields = ['username', 'email']
    readonly_fields = ['id']
    ordering = ['-id']

