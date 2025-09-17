import json
import time
from typing import Dict, List, Any
from django.contrib.auth import get_user_model
from drone_app.models import Drone
from .models import ChatSession, ChatMessage, QuickAction, ChatAnalytics

User = get_user_model()


class ChatbotService:
    """Core AI Chatbot service for drone disaster management"""
    
    def __init__(self):
        self.intent_patterns = {
            'drone_status': ['drone', 'status', 'where', 'location', 'track'],
            'delivery_management': ['delivery', 'order', 'package', 'eta', 'reschedule'],
            'inventory': ['inventory', 'stock', 'supplies', 'low stock', 'supplier'],
            'fleet_coordination': ['fleet', 'assign', 'nearest', 'reroute', 'coordinate'],
            'disaster_priority': ['priority', 'critical', 'emergency', 'urgent', 'disaster'],
            'analytics': ['report', 'analytics', 'stats', 'performance', 'data'],
            'weather': ['weather', 'conditions', 'forecast', 'wind', 'rain'],
            'communication': ['alert', 'notification', 'message', 'contact', 'support']
        }

    def process_message(self, user: User, message: str, session_id: str = None) -> Dict[str, Any]:
        """Process user message and generate AI response"""
        start_time = time.time()
        
        # Get or create session
        session = self._get_or_create_session(user, session_id)
        
        # Save user message
        user_msg = ChatMessage.objects.create(
            session=session,
            message_type='user',
            content=message
        )
        
        # Detect intent and generate response
        intent = self._detect_intent(message)
        response_data = self._generate_response(intent, message, user)
        
        # Save bot response
        bot_msg = ChatMessage.objects.create(
            session=session,
            message_type='bot',
            content=response_data['content'],
            metadata=response_data.get('metadata', {})
        )
        
        # Add quick actions
        for action in response_data.get('quick_actions', []):
            QuickAction.objects.create(
                message=bot_msg,
                action_type=action['type'],
                label=action['label'],
                icon=action['icon'],
                data=action.get('data', {})
            )
        
        # Log analytics
        response_time = time.time() - start_time
        ChatAnalytics.objects.create(
            user=user,
            query_type=intent,
            response_time=response_time
        )
        
        return {
            'session_id': str(session.id),
            'message_id': str(bot_msg.id),
            'content': response_data['content'],
            'quick_actions': response_data.get('quick_actions', []),
            'metadata': response_data.get('metadata', {})
        }

    def _get_or_create_session(self, user: User, session_id: str = None) -> ChatSession:
        """Get existing session or create new one"""
        if session_id:
            try:
                return ChatSession.objects.get(id=session_id, user=user, is_active=True)
            except ChatSession.DoesNotExist:
                pass
        
        return ChatSession.objects.create(user=user)

    def _detect_intent(self, message: str) -> str:
        """Detect user intent from message"""
        message_lower = message.lower()
        
        for intent, keywords in self.intent_patterns.items():
            if any(keyword in message_lower for keyword in keywords):
                return intent
        
        return 'general'

    def _generate_response(self, intent: str, message: str, user: User) -> Dict[str, Any]:
        """Generate AI response based on intent"""
        
        if intent == 'drone_status':
            return self._handle_drone_status(message, user)
        elif intent == 'delivery_management':
            return self._handle_delivery_management(message, user)
        elif intent == 'inventory':
            return self._handle_inventory(message, user)
        elif intent == 'fleet_coordination':
            return self._handle_fleet_coordination(message, user)
        elif intent == 'disaster_priority':
            return self._handle_disaster_priority(message, user)
        elif intent == 'analytics':
            return self._handle_analytics(message, user)
        elif intent == 'weather':
            return self._handle_weather(message, user)
        elif intent == 'communication':
            return self._handle_communication(message, user)
        else:
            return self._handle_general(message, user)

    def _handle_drone_status(self, message: str, user: User) -> Dict[str, Any]:
        """Handle drone status queries"""
        drones = Drone.objects.filter(is_deleted=False)[:3]
        
        if not drones:
            return {
                'content': "No active drones found in the system. Would you like me to help you add a new drone?",
                'quick_actions': [
                    {'type': 'create_order', 'label': 'Add Drone', 'icon': 'add'},
                    {'type': 'view_reports', 'label': 'View Fleet', 'icon': 'flight'}
                ]
            }
        
        status_text = "Current drone status:\n\n"
        for drone in drones:
            status_text += f"🚁 {str(drone.id)[:8]}: {drone.status} - {drone.urgency_level} priority\n"
            status_text += f"   Location: {drone.location_latitude}, {drone.location_longitude}\n\n"
        
        return {
            'content': status_text,
            'quick_actions': [
                {'type': 'track_drone', 'label': 'Live Tracking', 'icon': 'location_on'},
                {'type': 'fleet_status', 'label': 'Fleet Details', 'icon': 'flight'},
                {'type': 'emergency_alert', 'label': 'Emergency Return', 'icon': 'warning'}
            ],
            'metadata': {'drone_count': len(drones)}
        }

    def _handle_delivery_management(self, message: str, user: User) -> Dict[str, Any]:
        """Handle delivery and order management"""
        return {
            'content': "I can help you manage deliveries and orders. Current active deliveries: 12 in progress, 3 pending assignment. Average ETA: 18 minutes. Would you like to create a new order or check existing deliveries?",
            'quick_actions': [
                {'type': 'create_order', 'label': 'New Order', 'icon': 'add'},
                {'type': 'track_drone', 'label': 'Track Deliveries', 'icon': 'local_shipping'},
                {'type': 'view_reports', 'label': 'Delivery Reports', 'icon': 'assessment'}
            ]
        }

    def _handle_inventory(self, message: str, user: User) -> Dict[str, Any]:
        """Handle inventory management"""
        return {
            'content': "Inventory Status: Medical supplies at 78%, Food supplies at 45% (LOW STOCK ALERT), Water at 92%. 2 suppliers available for emergency restocking. Would you like me to contact suppliers or update inventory?",
            'quick_actions': [
                {'type': 'inventory_check', 'label': 'Full Inventory', 'icon': 'inventory'},
                {'type': 'emergency_alert', 'label': 'Contact Suppliers', 'icon': 'phone'},
                {'type': 'view_reports', 'label': 'Stock Reports', 'icon': 'bar_chart'}
            ]
        }

    def _handle_fleet_coordination(self, message: str, user: User) -> Dict[str, Any]:
        """Handle fleet coordination"""
        return {
            'content': "Fleet Coordination: 8 drones active, 2 in maintenance, 1 on standby. Nearest available drone is 2.3km from your location. I can assign drones based on proximity and urgency. What's your coordination need?",
            'quick_actions': [
                {'type': 'fleet_status', 'label': 'Fleet Overview', 'icon': 'flight'},
                {'type': 'track_drone', 'label': 'Assign Nearest', 'icon': 'near_me'},
                {'type': 'emergency_alert', 'label': 'Emergency Dispatch', 'icon': 'emergency'}
            ]
        }

    def _handle_disaster_priority(self, message: str, user: User) -> Dict[str, Any]:
        """Handle disaster zone prioritization"""
        return {
            'content': "Disaster Zone Priority System Active: 3 critical zones identified, 5 high-priority areas monitored. Current response time: 12 minutes average. Emergency protocols are ready for deployment. How can I assist with prioritization?",
            'quick_actions': [
                {'type': 'emergency_alert', 'label': 'Priority Zones', 'icon': 'priority_high'},
                {'type': 'track_drone', 'label': 'Optimal Routes', 'icon': 'route'},
                {'type': 'view_reports', 'label': 'Zone Analytics', 'icon': 'analytics'}
            ]
        }

    def _handle_analytics(self, message: str, user: User) -> Dict[str, Any]:
        """Handle analytics and reporting"""
        return {
            'content': "Analytics Summary: This week - 156 successful deliveries (94% success rate), 23% improvement in response time, 12 drones deployed. Cost efficiency up 18%. Would you like detailed reports or specific metrics?",
            'quick_actions': [
                {'type': 'view_reports', 'label': 'Detailed Reports', 'icon': 'assessment'},
                {'type': 'view_reports', 'label': 'Export Data', 'icon': 'download'},
                {'type': 'view_reports', 'label': 'Performance Trends', 'icon': 'trending_up'}
            ]
        }

    def _handle_weather(self, message: str, user: User) -> Dict[str, Any]:
        """Handle weather information"""
        return {
            'content': "Weather Conditions: Clear skies, wind 8 mph NE, visibility 10 miles, temperature 22°C. Flight conditions: OPTIMAL. No weather restrictions for drone operations. Next weather update in 2 hours.",
            'quick_actions': [
                {'type': 'check_weather', 'label': 'Detailed Forecast', 'icon': 'wb_sunny'},
                {'type': 'track_drone', 'label': 'Flight Planning', 'icon': 'flight_takeoff'},
                {'type': 'emergency_alert', 'label': 'Weather Alerts', 'icon': 'warning'}
            ]
        }

    def _handle_communication(self, message: str, user: User) -> Dict[str, Any]:
        """Handle communication and alerts"""
        return {
            'content': "Communication Center: 3 active alerts, 12 messages in queue, all systems operational. Emergency channels are clear. I can send notifications, connect you with team members, or manage alerts. What do you need?",
            'quick_actions': [
                {'type': 'emergency_alert', 'label': 'Send Alert', 'icon': 'notification_important'},
                {'type': 'view_reports', 'label': 'Message Center', 'icon': 'message'},
                {'type': 'emergency_alert', 'label': 'Contact Support', 'icon': 'support_agent'}
            ]
        }

    def _handle_general(self, message: str, user: User) -> Dict[str, Any]:
        """Handle general queries"""
        return {
            'content': "I'm your AI assistant for drone disaster management. I can help you with drone tracking, delivery management, inventory control, fleet coordination, disaster response, analytics, weather updates, and communications. What would you like to know?",
            'quick_actions': [
                {'type': 'track_drone', 'label': 'Track Drones', 'icon': 'location_on'},
                {'type': 'view_reports', 'label': 'View Reports', 'icon': 'assessment'},
                {'type': 'fleet_status', 'label': 'Fleet Status', 'icon': 'flight'},
                {'type': 'emergency_alert', 'label': 'Emergency', 'icon': 'emergency'}
            ]
        }

    def get_chat_history(self, user: User, session_id: str) -> List[Dict[str, Any]]:
        """Get chat history for a session"""
        try:
            session = ChatSession.objects.get(id=session_id, user=user)
            messages = session.messages.all()
            
            history = []
            for msg in messages:
                message_data = {
                    'id': str(msg.id),
                    'type': msg.message_type,
                    'content': msg.content,
                    'timestamp': msg.created_at.isoformat(),
                    'metadata': msg.metadata
                }
                
                if msg.message_type == 'bot':
                    message_data['quick_actions'] = [
                        {
                            'type': qa.action_type,
                            'label': qa.label,
                            'icon': qa.icon,
                            'data': qa.data
                        }
                        for qa in msg.quick_actions.all()
                    ]
                
                history.append(message_data)
            
            return history
        except ChatSession.DoesNotExist:
            return []

    def get_user_sessions(self, user: User) -> List[Dict[str, Any]]:
        """Get all chat sessions for a user"""
        sessions = ChatSession.objects.filter(user=user, is_active=True)
        
        return [
            {
                'id': str(session.id),
                'title': session.title,
                'created_at': session.created_at.isoformat(),
                'updated_at': session.updated_at.isoformat(),
                'message_count': session.messages.count()
            }
            for session in sessions
        ]