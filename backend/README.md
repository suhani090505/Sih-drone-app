# Django REST Framework Backend for Flutter Drone App

A comprehensive Django REST API backend for a Flutter drone management application with JWT authentication, PostgreSQL database, and full CRUD operations.

## Features

- **JWT Authentication** - Secure token-based authentication
- **Drone Management** - Complete CRUD operations for drone fleet
- **Fleet Status** - Real-time fleet monitoring and status tracking
- **Reports & Analytics** - Comprehensive reporting with export functionality
- **Admin Panel** - Django admin interface for backend management
- **CORS Support** - Ready for Flutter app integration

## Project Structure

```
backend/
├── drone_backend/          # Main Django project
│   ├── settings.py         # Django settings with PostgreSQL & JWT config
│   ├── urls.py            # Main URL routing
│   └── wsgi.py            # WSGI configuration
├── auth_app/              # Authentication app
│   ├── models.py          # Custom User model
│   ├── serializers.py     # Auth serializers
│   ├── views.py           # Auth endpoints
│   └── urls.py            # Auth URL patterns
├── drone_app/             # Drone management app
│   ├── models.py          # Drone model with UUID, location, status
│   ├── serializers.py     # Drone serializers
│   ├── views.py           # Drone CRUD endpoints
│   └── urls.py            # Drone URL patterns
├── fleet_app/             # Fleet management app
│   ├── views.py           # Fleet status endpoints
│   └── urls.py            # Fleet URL patterns
├── report_app/            # Reports and analytics app
│   ├── views.py           # Report generation & export
│   └── urls.py            # Report URL patterns
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables
├── test_api.py           # API testing script
└── README.md             # This file
```

## Installation & Setup

### Prerequisites

- Python 3.8+
- PostgreSQL 12+
- pip (Python package manager)

### 1. Clone and Setup

```bash
cd backend
pip install -r requirements.txt
```

### 2. Database Setup

Create PostgreSQL database:
```sql
CREATE DATABASE drone_db;
CREATE USER postgres WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE drone_db TO postgres;
```

### 3. Environment Configuration

Update `.env` file with your database credentials:
```env
SECRET_KEY=your-secret-key-here
DEBUG=True
DB_NAME=drone_db
DB_USER=postgres
DB_PASSWORD=your-password
DB_HOST=localhost
DB_PORT=5432
```

### 4. Run Migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Create Superuser

```bash
python manage.py createsuperuser
```

### 6. Start Development Server

```bash
python manage.py runserver
```

The API will be available at `http://127.0.0.1:8000`

## API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/register/` | Create new account | No |
| POST | `/auth/login/` | User login | No |
| POST | `/auth/forgot-password/` | Password reset | No |
| POST | `/auth/logout/` | User logout | Yes |

### Drone Management Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/drones/add/` | Add new drone | Yes |
| GET | `/drones/` | List all drones | Yes |
| PUT | `/drones/{id}/` | Update drone | Yes |
| DELETE | `/drones/{id}/delete/` | Soft delete drone | Yes |

### Fleet Management Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/fleet/` | Get fleet status | Yes |

### Reports Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/reports/overview/` | Get reports overview | Yes |
| GET | `/reports/export/` | Export data as CSV | Yes |

## Example API Responses

### Register Response
```json
{
  "message": "Account created successfully",
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com"
  },
  "tokens": {
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

### Drone List Response
```json
{
  "count": 2,
  "drones": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "location": {
        "latitude": 28.6139,
        "longitude": 77.2090
      },
      "package_details": {"weight": "2kg", "type": "medical"},
      "urgency_level": "High",
      "assigned_pilot": null,
      "assigned_pilot_name": null,
      "additional_note": "Emergency supply",
      "status": "Active",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Fleet Status Response
```json
{
  "summary": {
    "total_drones": 10,
    "active": 7,
    "maintenance": 2,
    "inactive": 1
  },
  "drones_by_status": {
    "active": [...],
    "maintenance": [...],
    "inactive": [...]
  },
  "status_distribution": {
    "Active": 7,
    "In Maintenance": 2,
    "Inactive": 1
  }
}
```

## Flutter Integration

### Base API Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String authEndpoint = '/auth';
  static const String dronesEndpoint = '/drones';
  static const String fleetEndpoint = '/fleet';
  static const String reportsEndpoint = '/reports';
}
```

### Token Storage

Store JWT tokens securely in Flutter:
```dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
  
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
}
```

### API Service Example

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    
    return json.decode(response.body);
  }
  
  static Future<Map<String, dynamic>> getDrones() async {
    final token = await TokenStorage.getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/drones/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    return json.decode(response.body);
  }
}
```

## Testing the API

Run the included test script:
```bash
python test_api.py
```

This will test all endpoints and verify the API is working correctly.

## Admin Panel

Access the Django admin panel at `http://127.0.0.1:8000/admin/` to:
- Manage users
- View and edit drones
- Monitor system activity
- Generate reports

## Production Deployment

For production deployment:

1. Set `DEBUG=False` in settings
2. Configure proper PostgreSQL database
3. Set up proper CORS origins
4. Use environment variables for sensitive data
5. Configure static files serving
6. Set up proper logging
7. Use HTTPS

## Security Features

- JWT token authentication
- Password validation
- CORS protection
- SQL injection prevention
- XSS protection
- CSRF protection

## Support

For issues and questions, refer to the Django and Django REST Framework documentation:
- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)