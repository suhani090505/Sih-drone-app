import re
import json
from typing import List, Dict, Any
from datetime import datetime, timedelta
from django.utils import timezone


class MessageProcessor:
    """Utility class for processing and analyzing messages"""
    
    @staticmethod
    def extract_entities(message: str) -> Dict[str, List[str]]:
        """Extract entities like drone IDs, locations, etc. from message"""
        entities = {
            'drone_ids': [],
            'locations': [],
            'urgency_levels': [],
            'numbers': []
        }
        
        # Extract drone IDs (pattern: DRONE-XXX or similar)
        drone_pattern = r'\b(?:drone|DRONE)[-_]?([A-Z0-9]+)\b'
        entities['drone_ids'] = re.findall(drone_pattern, message, re.IGNORECASE)
        
        # Extract urgency levels
        urgency_pattern = r'\b(critical|high|medium|low|urgent|emergency)\b'
        entities['urgency_levels'] = re.findall(urgency_pattern, message, re.IGNORECASE)
        
        # Extract numbers (for coordinates, distances, etc.)
        number_pattern = r'\b\d+(?:\.\d+)?\b'
        entities['numbers'] = re.findall(number_pattern, message)
        
        # Extract location-like terms
        location_pattern = r'\b(?:zone|area|sector|region|camp|station)\s+([A-Z0-9]+)\b'
        entities['locations'] = re.findall(location_pattern, message, re.IGNORECASE)
        
        return entities

    @staticmethod
    def calculate_response_priority(message: str, user_context: Dict = None) -> int:
        """Calculate response priority (1-5, 5 being highest)"""
        priority = 1
        message_lower = message.lower()
        
        # Emergency keywords increase priority
        emergency_keywords = ['emergency', 'critical', 'urgent', 'help', 'sos', 'disaster']
        for keyword in emergency_keywords:
            if keyword in message_lower:
                priority = max(priority, 5)
                break
        
        # High priority keywords
        high_priority_keywords = ['battery', 'crash', 'lost', 'malfunction', 'error']
        for keyword in high_priority_keywords:
            if keyword in message_lower:
                priority = max(priority, 4)
        
        # Medium priority keywords
        medium_priority_keywords = ['status', 'location', 'eta', 'delivery']
        for keyword in medium_priority_keywords:
            if keyword in message_lower:
                priority = max(priority, 3)
        
        return priority

    @staticmethod
    def format_response_with_context(base_response: str, context: Dict[str, Any]) -> str:
        """Format response with dynamic context data"""
        try:
            # Replace placeholders in response with context data
            formatted_response = base_response
            
            for key, value in context.items():
                placeholder = f"{{{key}}}"
                if placeholder in formatted_response:
                    formatted_response = formatted_response.replace(placeholder, str(value))
            
            return formatted_response
        except Exception:
            return base_response


class NotificationManager:
    """Utility class for managing notifications and alerts"""
    
    @staticmethod
    def create_push_notification(user_id: int, title: str, message: str, 
                                priority: str = 'normal', data: Dict = None) -> Dict[str, Any]:
        """Create push notification payload"""
        return {
            'user_id': user_id,
            'title': title,
            'message': message,
            'priority': priority,
            'data': data or {},
            'timestamp': timezone.now().isoformat(),
            'type': 'chatbot_notification'
        }

    @staticmethod
    def should_send_notification(last_activity: datetime, message_priority: int) -> bool:
        """Determine if notification should be sent based on activity and priority"""
        if message_priority >= 4:  # High/Critical priority
            return True
        
        # Send notification if user hasn't been active for 5+ minutes
        inactive_threshold = timezone.now() - timedelta(minutes=5)
        return last_activity < inactive_threshold


class AnalyticsHelper:
    """Utility class for analytics and reporting"""
    
    @staticmethod
    def calculate_response_metrics(response_times: List[float]) -> Dict[str, float]:
        """Calculate response time metrics"""
        if not response_times:
            return {'avg': 0, 'min': 0, 'max': 0, 'median': 0}
        
        sorted_times = sorted(response_times)
        n = len(sorted_times)
        
        return {
            'avg': sum(sorted_times) / n,
            'min': sorted_times[0],
            'max': sorted_times[-1],
            'median': sorted_times[n // 2] if n % 2 == 1 else 
                     (sorted_times[n // 2 - 1] + sorted_times[n // 2]) / 2
        }

    @staticmethod
    def generate_usage_report(user_id: int, days: int = 7) -> Dict[str, Any]:
        """Generate usage report for a user"""
        from .models import ChatAnalytics, ChatSession
        
        end_date = timezone.now()
        start_date = end_date - timedelta(days=days)
        
        # Get analytics data
        analytics = ChatAnalytics.objects.filter(
            user_id=user_id,
            created_at__range=[start_date, end_date]
        )
        
        # Get session data
        sessions = ChatSession.objects.filter(
            user_id=user_id,
            created_at__range=[start_date, end_date]
        )
        
        response_times = [a.response_time for a in analytics]
        satisfaction_scores = [a.satisfaction_score for a in analytics if a.satisfaction_score]
        
        return {
            'period': f'{days} days',
            'total_queries': analytics.count(),
            'total_sessions': sessions.count(),
            'avg_satisfaction': sum(satisfaction_scores) / len(satisfaction_scores) if satisfaction_scores else 0,
            'response_metrics': AnalyticsHelper.calculate_response_metrics(response_times),
            'most_common_queries': list(analytics.values_list('query_type', flat=True)[:5])
        }


class MultilingualSupport:
    """Utility class for multilingual support (placeholder for future implementation)"""
    
    SUPPORTED_LANGUAGES = {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'hi': 'Hindi',
        'zh': 'Chinese'
    }
    
    @staticmethod
    def detect_language(text: str) -> str:
        """Detect language of input text (placeholder)"""
        # Placeholder for language detection
        # In production, integrate with language detection service
        return 'en'
    
    @staticmethod
    def translate_response(text: str, target_language: str) -> str:
        """Translate response to target language (placeholder)"""
        # Placeholder for translation
        # In production, integrate with translation service
        return text
    
    @staticmethod
    def get_localized_quick_actions(language: str) -> Dict[str, str]:
        """Get localized quick action labels"""
        # Placeholder for localized quick actions
        default_actions = {
            'track_drone': 'Track Drone',
            'view_reports': 'View Reports',
            'check_weather': 'Check Weather',
            'fleet_status': 'Fleet Status',
            'create_order': 'Create Order',
            'inventory_check': 'Inventory Check',
            'emergency_alert': 'Emergency Alert'
        }
        
        # In production, load from localization files
        return default_actions


class VoiceProcessor:
    """Utility class for voice processing (placeholder for future implementation)"""
    
    @staticmethod
    def speech_to_text(audio_data: bytes) -> str:
        """Convert speech to text (placeholder)"""
        # Placeholder for speech-to-text processing
        # In production, integrate with speech recognition service
        return "Voice processing not implemented yet"
    
    @staticmethod
    def text_to_speech(text: str, language: str = 'en') -> bytes:
        """Convert text to speech (placeholder)"""
        # Placeholder for text-to-speech processing
        # In production, integrate with TTS service
        return b"Audio data placeholder"
    
    @staticmethod
    def is_voice_command(text: str) -> bool:
        """Check if text contains voice command indicators"""
        voice_indicators = ['voice:', 'speak:', 'say:', 'audio:']
        return any(indicator in text.lower() for indicator in voice_indicators)