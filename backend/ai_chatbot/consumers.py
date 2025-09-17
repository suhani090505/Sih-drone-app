import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .services import ChatbotService

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    """WebSocket consumer for real-time chat functionality"""
    
    async def connect(self):
        """Handle WebSocket connection"""
        self.user = self.scope["user"]
        
        if self.user.is_anonymous:
            await self.close()
            return
        
        self.room_name = f"chat_{self.user.id}"
        self.room_group_name = f"chat_group_{self.user.id}"
        
        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        
        await self.accept()
        
        # Send welcome message
        await self.send(text_data=json.dumps({
            'type': 'system_message',
            'message': 'Connected to AI Chatbot. How can I help you today?'
        }))

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def receive(self, text_data):
        """Handle incoming WebSocket messages"""
        try:
            text_data_json = json.loads(text_data)
            message_type = text_data_json.get('type', 'chat_message')
            
            if message_type == 'chat_message':
                await self.handle_chat_message(text_data_json)
            elif message_type == 'quick_action':
                await self.handle_quick_action(text_data_json)
            elif message_type == 'typing':
                await self.handle_typing_indicator(text_data_json)
                
        except json.JSONDecodeError:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Invalid JSON format'
            }))

    async def handle_chat_message(self, data):
        """Handle chat message processing"""
        message = data.get('message', '').strip()
        session_id = data.get('session_id')
        
        if not message:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Message cannot be empty'
            }))
            return
        
        # Send typing indicator
        await self.send(text_data=json.dumps({
            'type': 'bot_typing',
            'is_typing': True
        }))
        
        # Process message with chatbot service
        response_data = await self.process_chatbot_message(message, session_id)
        
        # Send bot response
        await self.send(text_data=json.dumps({
            'type': 'bot_message',
            'message_id': response_data['message_id'],
            'content': response_data['content'],
            'quick_actions': response_data.get('quick_actions', []),
            'metadata': response_data.get('metadata', {}),
            'session_id': response_data['session_id']
        }))
        
        # Stop typing indicator
        await self.send(text_data=json.dumps({
            'type': 'bot_typing',
            'is_typing': False
        }))

    async def handle_quick_action(self, data):
        """Handle quick action processing"""
        action_type = data.get('action_type')
        action_data = data.get('data', {})
        session_id = data.get('session_id')
        
        if not action_type:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': 'Action type is required'
            }))
            return
        
        # Process quick action
        response_data = await self.process_quick_action(action_type, action_data, session_id)
        
        await self.send(text_data=json.dumps({
            'type': 'quick_action_response',
            'action_type': action_type,
            'response': response_data
        }))

    async def handle_typing_indicator(self, data):
        """Handle typing indicator from user"""
        is_typing = data.get('is_typing', False)
        
        # Broadcast typing status to room (for future multi-user support)
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'user_typing',
                'user_id': self.user.id,
                'is_typing': is_typing
            }
        )

    @database_sync_to_async
    def process_chatbot_message(self, message, session_id):
        """Process message with chatbot service (database operation)"""
        chatbot_service = ChatbotService()
        return chatbot_service.process_message(
            user=self.user,
            message=message,
            session_id=session_id
        )

    @database_sync_to_async
    def process_quick_action(self, action_type, action_data, session_id):
        """Process quick action (database operation)"""
        from .views import _process_quick_action
        return _process_quick_action(action_type, action_data, self.user, session_id)

    # Group message handlers
    async def user_typing(self, event):
        """Handle user typing broadcast"""
        await self.send(text_data=json.dumps({
            'type': 'user_typing',
            'user_id': event['user_id'],
            'is_typing': event['is_typing']
        }))

    async def system_notification(self, event):
        """Handle system notifications"""
        await self.send(text_data=json.dumps({
            'type': 'system_notification',
            'message': event['message'],
            'priority': event.get('priority', 'normal')
        }))