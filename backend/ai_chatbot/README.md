# AI Chatbot Module for Drone Disaster Management System

## Overview

The AI Chatbot Module provides intelligent conversational assistance for drone disaster management operations. It integrates seamlessly with the Django backend and Flutter frontend to deliver real-time support for order management, inventory control, fleet coordination, disaster response, and analytics.

## Features

### Core Functionalities

1. **Order & Delivery Management**
   - Create and track delivery requests
   - Assign drones to orders
   - Reschedule deliveries
   - Provide ETAs and status updates

2. **Inventory Management**
   - View and update stock levels
   - Low-stock alerts and notifications
   - Connect with alternate suppliers
   - Inventory analytics and reporting

3. **Drone Fleet Coordination**
   - Real-time drone tracking
   - Assign nearest available drones
   - Route optimization and rerouting
   - Fleet status monitoring

4. **Disaster Zone Prioritization**
   - Critical order priority management
   - Optimal path suggestions
   - Emergency response protocols
   - Zone-based resource allocation

5. **Communication & Alerts**
   - Push notifications
   - Supplier-manager communication
   - System alerts and warnings
   - Emergency notifications

6. **Analytics & Reports**
   - Daily and weekly performance reports
   - Efficiency metrics (20% time reduction tracking)
   - Drone statistics and analytics
   - Custom report generation

7. **Voice & Multilingual Support**
   - Text and voice input processing
   - Multi-language support (prepared)
   - Speech-to-text conversion (placeholder)

## Architecture

### Backend Components

```
ai_chatbot/
├── models.py          # Database models for chat sessions, messages, analytics
├── views.py           # API endpoints for chat functionality
├── services.py        # Core chatbot logic and AI processing
├── urls.py            # URL routing configuration
├── consumers.py       # WebSocket consumers for real-time chat
├── utils.py           # Utility functions and helpers
├── admin.py           # Django admin interface
└── migrations/        # Database migrations
```

### Database Models

- **ChatSession**: User chat sessions with metadata
- **ChatMessage**: Individual messages with type and content
- **QuickAction**: Interactive buttons for quick responses
- **ChatAnalytics**: Performance metrics and user feedback

### API Endpoints

- `POST /api/chatbot/chat/` - Send chat message
- `GET /api/chatbot/history/<session_id>/` - Get chat history
- `GET /api/chatbot/sessions/` - Get user sessions
- `POST /api/chatbot/quick-action/` - Execute quick actions
- `POST /api/chatbot/feedback/` - Submit user feedback
- `POST /api/chatbot/voice-to-text/` - Voice processing (placeholder)

## Setup Instructions

### 1. Django Backend Setup

1. **Install Dependencies**
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Add to Django Settings**
   The module is already added to `INSTALLED_APPS` in `settings.py`:
   ```python
   INSTALLED_APPS = [
       # ... other apps
       'ai_chatbot',
   ]
   ```

3. **Run Migrations**
   ```bash
   python manage.py makemigrations ai_chatbot
   python manage.py migrate
   ```

4. **Create Superuser (Optional)**
   ```bash
   python manage.py createsuperuser
   ```

5. **Start Development Server**
   ```bash
   python manage.py runserver
   ```

### 2. Flutter Frontend Integration

1. **Add HTTP Dependency**
   Add to `pubspec.yaml`:
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. **Import Services**
   The chat service is already integrated in the existing chatbot screen:
   ```dart
   import '../services/chat_service.dart';
   import '../models/chat_models.dart';
   ```

3. **Configure API Endpoint**
   Update the base URL in `chat_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-server:8000/api/chatbot';
   ```

4. **Set Authentication Token**
   ```dart
   ChatService.setAuthToken('your-jwt-token');
   ```

## Usage Examples

### Sending a Chat Message

```dart
final response = await ChatService.sendMessage(
  message: 'What is the status of Drone A3?',
  sessionId: currentSessionId,
);
```

### Executing Quick Actions

```dart
final response = await ChatService.executeQuickAction(
  actionType: 'track_drone',
  data: {'drone_id': 'A3'},
  sessionId: currentSessionId,
);
```

### Backend Service Usage

```python
from ai_chatbot.services import ChatbotService

chatbot = ChatbotService()
response = chatbot.process_message(
    user=request.user,
    message="Show me drone status",
    session_id=session_id
)
```

## Current Implementation (SQLite)

The module currently uses SQLite for data storage, which is suitable for:
- Development and testing
- Small to medium deployments
- Single-server setups
- Quick prototyping

### SQLite Benefits
- Zero configuration
- File-based storage
- ACID compliance
- Cross-platform compatibility
- Integrated with Django ORM

## Future Redis Upgrade Path

### Why Redis?

For production deployments with high concurrency and real-time requirements, Redis provides:
- **Real-time messaging**: WebSocket support with channels
- **Session management**: Distributed session storage
- **Caching**: Fast response times for frequent queries
- **Pub/Sub**: Real-time notifications and alerts
- **Scalability**: Horizontal scaling support

### Migration Steps

1. **Install Redis Dependencies**
   ```bash
   pip install redis channels-redis
   ```

2. **Update Django Settings**
   ```python
   CHANNEL_LAYERS = {
       'default': {
           'BACKEND': 'channels_redis.core.RedisChannelLayer',
           'CONFIG': {
               'hosts': [('127.0.0.1', 6379)],
           },
       },
   }
   
   CACHES = {
       'default': {
           'BACKEND': 'django_redis.cache.RedisCache',
           'LOCATION': 'redis://127.0.0.1:6379/1',
           'OPTIONS': {
               'CLIENT_CLASS': 'django_redis.client.DefaultClient',
           }
       }
   }
   ```

3. **Enable WebSocket Support**
   ```python
   # asgi.py
   import os
   from channels.routing import ProtocolTypeRouter, URLRouter
   from channels.auth import AuthMiddlewareStack
   from django.core.asgi import get_asgi_application
   from ai_chatbot import routing
   
   application = ProtocolTypeRouter({
       'http': get_asgi_application(),
       'websocket': AuthMiddlewareStack(
           URLRouter(
               routing.websocket_urlpatterns
           )
       ),
   })
   ```

4. **Update Frontend for WebSocket**
   ```dart
   // Use WebSocket for real-time communication
   final channel = WebSocketChannel.connect(
     Uri.parse('ws://localhost:8000/ws/chat/'),
   );
   ```

## Performance Optimizations

### Current Optimizations
- Efficient database queries with select_related
- Response caching for common queries
- Minimal API payload sizes
- Optimized message processing

### Future Optimizations
- Redis caching for frequent responses
- WebSocket connections for real-time updates
- Message queuing for high-volume processing
- CDN integration for static assets

## Security Considerations

- JWT authentication for API access
- Input validation and sanitization
- Rate limiting for API endpoints
- CORS configuration for cross-origin requests
- Secure WebSocket connections (WSS)

## Monitoring and Analytics

### Built-in Analytics
- Response time tracking
- User satisfaction scoring
- Query type analysis
- Session duration metrics

### Integration Points
- Django admin interface for data management
- Custom analytics dashboard
- Export capabilities for reporting
- Real-time monitoring dashboards

## Testing

### Backend Tests
```bash
python manage.py test ai_chatbot
```

### API Testing
```bash
# Test chat endpoint
curl -X POST http://localhost:8000/api/chatbot/chat/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-token" \
  -d '{"message": "Hello AI"}'
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure JWT token is properly set
   - Check token expiration
   - Verify user permissions

2. **Connection Issues**
   - Verify Django server is running
   - Check CORS configuration
   - Confirm API endpoint URLs

3. **Database Issues**
   - Run migrations: `python manage.py migrate`
   - Check database permissions
   - Verify model relationships

### Debug Mode

Enable debug logging in Django settings:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'ai_chatbot': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    },
}
```

## Contributing

1. Follow Django coding standards
2. Add tests for new features
3. Update documentation
4. Use meaningful commit messages
5. Test with both SQLite and Redis configurations

## License

This module is part of the Drone Disaster Management System and follows the same licensing terms as the main project.

## Support

For technical support and questions:
- Check the troubleshooting section
- Review Django and Flutter documentation
- Submit issues through the project repository
- Contact the development team

---

**Note**: This module is designed to be production-ready with SQLite for immediate deployment and includes a clear upgrade path to Redis for enhanced scalability and real-time features.