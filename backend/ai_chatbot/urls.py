from django.urls import path
from . import views

app_name = 'ai_chatbot'

urlpatterns = [
    path('chat/', views.chat_message, name='chat_message'),
    path('history/<uuid:session_id>/', views.chat_history, name='chat_history'),
    path('sessions/', views.user_sessions, name='user_sessions'),
    path('quick-action/', views.quick_action, name='quick_action'),
    path('voice-to-text/', views.voice_to_text, name='voice_to_text'),
    path('feedback/', views.feedback, name='feedback'),
]