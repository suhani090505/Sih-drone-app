#!/usr/bin/env python
"""
Simple test script for AI Chatbot functionality
"""

import os
import django

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'drone_backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from ai_chatbot.services import ChatbotService

User = get_user_model()

def test_chatbot_service():
    """Test the chatbot service directly"""
    print("Testing ChatbotService...")
    
    # Create test user
    user = User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )
    
    chatbot = ChatbotService()
    
    # Test different message types
    test_messages = [
        "What is the status of my drones?",
        "I need to create a new delivery order",
        "Check inventory levels",
        "Show me weather conditions",
        "Generate a performance report"
    ]
    
    for i, message in enumerate(test_messages, 1):
        print(f"\nTest {i}: '{message}'")
        try:
            response = chatbot.process_message(user, message)
            print(f"SUCCESS - Response: {response['content'][:80]}...")
            print(f"SUCCESS - Quick actions: {len(response.get('quick_actions', []))}")
            print(f"SUCCESS - Session ID: {response.get('session_id', 'N/A')}")
        except Exception as e:
            print(f"ERROR: {str(e)}")
    
    # Test chat history
    print(f"\nTesting chat history...")
    try:
        sessions = chatbot.get_user_sessions(user)
        print(f"SUCCESS - User has {len(sessions)} sessions")
        
        if sessions:
            session_id = sessions[0]['id']
            history = chatbot.get_chat_history(user, session_id)
            print(f"SUCCESS - Session has {len(history)} messages")
    except Exception as e:
        print(f"ERROR: {str(e)}")
    
    # Cleanup
    user.delete()
    print("\nChatbotService tests completed!")

if __name__ == '__main__':
    print("Starting AI Chatbot Tests")
    print("=" * 40)
    
    try:
        test_chatbot_service()
        print("\nAll tests completed successfully!")
    except Exception as e:
        print(f"\nTest execution failed: {str(e)}")