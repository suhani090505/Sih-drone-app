# DroneOps Flutter App

A Flutter application for drone operations management with integrated authentication system.

## Features

- **User Authentication**: Login and registration with JWT token management
- **Secure Storage**: User credentials and tokens stored securely using `flutter_secure_storage`
- **Django Integration**: Seamless connection to Django REST Framework backend
- **Responsive Design**: Works on mobile, tablet, and desktop platforms

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Django backend running (see backend setup)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Sih-drone-app/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**
   
   Edit `lib/services/auth_service.dart` and update the `_baseUrl` constant:
   ```dart
   static const String _baseUrl = 'http://YOUR_IP_ADDRESS:8000';
   ```
   
   **For local development:**
   - Use your computer's IP address (e.g., `http://192.168.1.100:8000`)
   - Find your IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Ensure your Django backend is running on `0.0.0.0:8000`

4. **Run the application**
   ```bash
   flutter run
   ```

## Authentication System

### Login Flow

1. **User enters username and password**
2. **App sends POST request to `/api/auth/login/`**
3. **On success**: JWT tokens are stored securely and user is redirected to dashboard
4. **On failure**: Error message is displayed
5. **Account not found**: Dialog prompts user to create an account

### Registration Flow

1. **User clicks "Create Account" from login screen**
2. **Navigates to separate signup screen**
3. **User fills in username, email, password, and confirm password**
4. **App sends POST request to `/api/auth/register/`**
5. **On success**: User data and tokens are stored, redirected to dashboard
6. **On failure**: Error message is displayed (e.g., "User already exists")

### JWT Token Management

- **Storage**: Tokens are stored using `flutter_secure_storage` for maximum security
- **Access Token**: Used for API authentication
- **Refresh Token**: Used to obtain new access tokens
- **User Data**: Username, email, and user ID are stored locally

### Stored Data

The following data is securely stored locally:
- `access_token`: JWT access token for API requests
- `refresh_token`: JWT refresh token for token renewal
- `username`: User's username
- `email`: User's email address
- `user_id`: User's unique identifier

## Testing Authentication

### Backend Setup

1. **Start Django backend**
   ```bash
   cd backend
   python manage.py runserver 0.0.0.0:8000
   ```

2. **Create test user (optional)**
   ```bash
   python manage.py shell
   ```
   ```python
   from auth_app.models import User
   User.objects.create_user(username='testuser', email='test@example.com', password='testpass123')
   ```

### Testing Login

1. **Valid credentials**: Use existing username/password
2. **Invalid credentials**: Try wrong password - should show "Invalid username or password"
3. **Non-existent user**: Try non-existent username - should prompt to create account

### Testing Registration

1. **New user**: Fill all fields with new username/email
2. **Existing user**: Try existing username - should show "User already exists"
3. **Password mismatch**: Different passwords - should show "Passwords do not match"
4. **Empty fields**: Leave fields empty - should show validation errors

## API Endpoints

- **Login**: `POST /api/auth/login/`
  ```json
  {
    "username": "string",
    "password": "string"
  }
  ```

- **Register**: `POST /api/auth/register/`
  ```json
  {
    "username": "string",
    "email": "string",
    "password": "string"
  }
  ```

## File Structure

```
lib/
├── services/
│   ├── auth_service.dart          # Authentication API service
│   ├── chat_service.dart          # Existing chat service
│   └── notification_service.dart  # Existing notification service
├── screens/
│   ├── auth_screen.dart           # Updated login screen
│   ├── signup_screen.dart         # New registration screen
│   └── ...                        # Other existing screens
└── ...
```

## Dependencies

- `flutter_secure_storage: ^9.0.0` - Secure local storage for tokens
- `dio: ^5.3.2` - HTTP client for API requests
- `provider: ^6.1.1` - State management
- `http: ^1.1.0` - Alternative HTTP client

## Troubleshooting

### Common Issues

1. **Network Error**
   - Check if Django backend is running
   - Verify the API base URL in `auth_service.dart`
   - Ensure your device/emulator can reach the backend IP

2. **Token Storage Issues**
   - Clear app data and try again
   - Check device permissions for secure storage

3. **CORS Issues**
   - Ensure Django CORS settings allow your Flutter app's origin
   - Check Django `ALLOWED_HOSTS` setting

### Debug Mode

To enable debug logging, add print statements in `auth_service.dart`:
```dart
print('Login request: ${response.data}');
```

## Security Notes

- Tokens are stored using platform-specific secure storage (Keychain on iOS, Keystore on Android)
- Passwords are never stored locally
- All API communication should use HTTPS in production
- Implement token refresh logic for production use
