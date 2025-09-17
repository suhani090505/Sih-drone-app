from django.urls import path
from . import views

# Auth endpoints under /api/auth/
urlpatterns = [
    path('register/', views.register, name='auth_register'),
    path('login/', views.login, name='auth_login'),
    path('forgot-password/', views.forgot_password, name='auth_forgot_password'),
    path('logout/', views.logout, name='auth_logout'),
    path('users/', views.get_users, name='get_users'),
]