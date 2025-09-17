from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import JsonResponse
import json

from .services import ChatbotService
from .models import ChatSession, ChatMessage


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def chat_message(request):
    """Handle chat message from user"""
    try:
        data = json.loads(request.body)
        message = data.get('message', '').strip()
        session_id = data.get('session_id')
        
        if not message:
            return Response(
                {'error': 'Message cannot be empty'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        chatbot_service = ChatbotService()
        response_data = chatbot_service.process_message(
            user=request.user,
            message=message,
            session_id=session_id
        )
        
        return Response(response_data, status=status.HTTP_200_OK)
        
    except json.JSONDecodeError:
        return Response(
            {'error': 'Invalid JSON format'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def chat_history(request, session_id):
    """Get chat history for a session"""
    try:
        chatbot_service = ChatbotService()
        history = chatbot_service.get_chat_history(request.user, session_id)
        
        return Response({
            'session_id': session_id,
            'messages': history
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_sessions(request):
    """Get all chat sessions for the user"""
    try:
        chatbot_service = ChatbotService()
        sessions = chatbot_service.get_user_sessions(request.user)
        
        return Response({
            'sessions': sessions
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def quick_action(request):
    """Handle quick action clicks"""
    try:
        data = json.loads(request.body)
        action_type = data.get('action_type')
        action_data = data.get('data', {})
        session_id = data.get('session_id')
        
        if not action_type:
            return Response(
                {'error': 'Action type is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Process quick action
        response_data = _process_quick_action(action_type, action_data, request.user, session_id)
        
        return Response(response_data, status=status.HTTP_200_OK)
        
    except json.JSONDecodeError:
        return Response(
            {'error': 'Invalid JSON format'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def voice_to_text(request):
    """Convert voice input to text (placeholder for future implementation)"""
    try:
        # Placeholder for voice processing
        # In production, integrate with speech-to-text service
        return Response({
            'text': 'Voice processing not implemented yet. Please use text input.',
            'success': False
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def feedback(request):
    """Handle user feedback on chatbot responses"""
    try:
        data = json.loads(request.body)
        message_id = data.get('message_id')
        rating = data.get('rating')  # 1-5 scale
        feedback_text = data.get('feedback', '')
        
        if not message_id or not rating:
            return Response(
                {'error': 'Message ID and rating are required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update analytics with feedback
        from .models import ChatAnalytics
        try:
            message = ChatMessage.objects.get(id=message_id)
            analytics = ChatAnalytics.objects.filter(
                user=request.user,
                created_at__gte=message.created_at
            ).first()
            
            if analytics:
                analytics.satisfaction_score = rating
                analytics.save()
        except ChatMessage.DoesNotExist:
            pass
        
        return Response({
            'message': 'Feedback recorded successfully'
        }, status=status.HTTP_200_OK)
        
    except json.JSONDecodeError:
        return Response(
            {'error': 'Invalid JSON format'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


def _process_quick_action(action_type: str, action_data: dict, user, session_id: str):
    """Process quick action and return appropriate response"""
    
    action_responses = {
        'track_drone': {
            'message': 'Opening live drone tracking interface...',
            'action': 'navigate',
            'target': '/tracking'
        },
        'view_reports': {
            'message': 'Loading analytics dashboard...',
            'action': 'navigate',
            'target': '/reports'
        },
        'check_weather': {
            'message': 'Fetching latest weather data...',
            'action': 'modal',
            'data': {
                'temperature': '22°C',
                'wind': '8 mph NE',
                'visibility': '10 miles',
                'conditions': 'Clear'
            }
        },
        'fleet_status': {
            'message': 'Displaying fleet status overview...',
            'action': 'navigate',
            'target': '/fleet'
        },
        'create_order': {
            'message': 'Opening order creation form...',
            'action': 'modal',
            'target': 'create_order'
        },
        'inventory_check': {
            'message': 'Loading inventory management system...',
            'action': 'navigate',
            'target': '/inventory'
        },
        'emergency_alert': {
            'message': 'Activating emergency protocols...',
            'action': 'alert',
            'priority': 'high'
        }
    }
    
    response = action_responses.get(action_type, {
        'message': 'Processing your request...',
        'action': 'none'
    })
    
    # Save action as system message if session exists
    if session_id:
        try:
            session = ChatSession.objects.get(id=session_id, user=user)
            ChatMessage.objects.create(
                session=session,
                message_type='system',
                content=f"Quick action: {action_type}",
                metadata={'action_data': action_data}
            )
        except ChatSession.DoesNotExist:
            pass
    
    return response