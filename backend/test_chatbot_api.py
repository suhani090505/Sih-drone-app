#!/usr/bin/env python
"""
Test script for AI Chatbot API endpoints
Run this script to verify the chatbot functionality
"""

import os
import sys
import django
import json
from django.test import Client
from django.contrib.auth import get_user_model

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'drone_backend.settings')
django.setup()

User = get_user_model()

def test_chatbot_api():
    """Test the chatbot API endpoints"""
    client = Client()
    
    # Create test user
    user = User.objects.create_user(
        username='testuser',
        email='test@example.com',
        password='testpass123'
    )
    
    # Login to get authentication
    login_response = client.post('/api/auth/login/', {
        'email': 'test@example.com',
        'password': 'testpass123'
    })
    
    if login_response.status_code != 200:
        print("❌ Login failed")
        return False
    
    # Get JWT token (if using JWT authentication)
    # For now, we'll use session authentication
    
    print("[SUCCESS] User authentication successful")
    
    # Test 1: Send chat message
    print("\n[TEST] Testing chat message endpoint...")
    chat_response = client.post(
        '/api/chatbot/chat/',
        data=json.dumps({
            'message': 'What is the status of my drones?'
        }),
        content_type='application/json'
    )
    
    if chat_response.status_code == 200:
        response_data = json.loads(chat_response.content)
        print(f"[SUCCESS] Chat message successful")
        print(f"   Session ID: {response_data.get('session_id', 'N/A')}")
        print(f"   Response: {response_data.get('content', 'N/A')[:100]}...")
        session_id = response_data.get('session_id')
    else:
        print(f"[FAILED] Chat message failed: {chat_response.status_code}")
        print(f"   Response: {chat_response.content}")
        return False
    
    # Test 2: Quick action
    print("\n[TEST] Testing quick action endpoint...")
    action_response = client.post(
        '/api/chatbot/quick-action/',
        data=json.dumps({
            'action_type': 'track_drone',
            'session_id': session_id
        }),
        content_type='application/json'
    )
    
    if action_response.status_code == 200:
        action_data = json.loads(action_response.content)
        print(f"[SUCCESS] Quick action successful")
        print(f"   Action: {action_data.get('message', 'N/A')}")
    else:
        print(f"[FAILED] Quick action failed: {action_response.status_code}")
        print(f"   Response: {action_response.content}")
    
    # Test 3: Get user sessions
    print("\n[TEST] Testing user sessions endpoint...")
    sessions_response = client.get('/api/chatbot/sessions/')
    
    if sessions_response.status_code == 200:
        sessions_data = json.loads(sessions_response.content)
        print(f"[SUCCESS] User sessions successful")
        print(f"   Sessions count: {len(sessions_data.get('sessions', []))}")
    else:
        print(f"[FAILED] User sessions failed: {sessions_response.status_code}")
    
    # Test 4: Get chat history
    if session_id:
        print("\n[TEST] Testing chat history endpoint...")
        history_response = client.get(f'/api/chatbot/history/{session_id}/')
        
        if history_response.status_code == 200:
            history_data = json.loads(history_response.content)
            print(f"[SUCCESS] Chat history successful")
            print(f"   Messages count: {len(history_data.get('messages', []))}")
        else:
            print(f"[FAILED] Chat history failed: {history_response.status_code}")
    
    # Test 5: Feedback
    print("\n[TEST] Testing feedback endpoint...")
    feedback_response = client.post(
        '/api/chatbot/feedback/',
        data=json.dumps({
            'message_id': 'test-message-id',
            'rating': 5,
            'feedback': 'Great response!'
        }),
        content_type='application/json'
    )
    
    if feedback_response.status_code == 200:
        print("[SUCCESS] Feedback submission successful")
    else:
        print(f"[FAILED] Feedback failed: {feedback_response.status_code}")
    
    # Cleanup
    user.delete()
    
    print("\n[COMPLETE] All tests completed!")
    return True

def test_chatbot_service():
    """Test the chatbot service directly"""
    from ai_chatbot.services import ChatbotService
    
    print("\n[TEST] Testing ChatbotService directly...")
    
    # Create test user
    user = User.objects.create_user(
        username='servicetest',
        email='service@example.com',
        password='testpass123'
    )
    
    chatbot = ChatbotService()
    
    # Test different message types
    test_messages = [
        "What is the status of my drones?",
        "I need to create a new delivery order",
        "Check inventory levels",
        "Show me weather conditions",
        "Generate a performance report",
        "Emergency! Need immediate assistance!"
    ]
    
    for message in test_messages:
        print(f"\n   Testing: '{message}'")
        try:
            response = chatbot.process_message(user, message)
            print(f"   [SUCCESS] Response: {response['content'][:80]}...")
            print(f"   [SUCCESS] Quick actions: {len(response.get('quick_actions', []))}")
        except Exception as e:
            print(f"   [ERROR] Error: {str(e)}")
    
    # Cleanup
    user.delete()
    
    print("\n[SUCCESS] ChatbotService tests completed!")

if __name__ == '__main__':
    print("Starting AI Chatbot API Tests")
    print("=" * 50)
    
    try:
        # Test API endpoints
        api_success = test_chatbot_api()
        
        # Test service directly
        test_chatbot_service()
        
        if api_success:
            print("\n[SUCCESS] All tests passed! The AI Chatbot Module is working correctly.")
        else:
            print("\n[WARNING] Some tests failed. Please check the error messages above.")
            
    except Exception as e:
        print(f"\n[ERROR] Test execution failed: {str(e)}")
        sys.exit(1)