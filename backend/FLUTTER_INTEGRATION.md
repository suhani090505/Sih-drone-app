# Flutter Integration Guide

## API Base URL Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
  
  // Endpoints
  static const String healthCheck = '/';
  static const String auth = '/api/auth';
  static const String drones = '/api/drones';
  static const String fleet = '/api/fleet';
  static const String reports = '/api/reports';
  static const String dashboard = '/api/dashboard';
}
```

## App Flow Integration

### 1. App Launch Flow
```dart
// Check if user is first time
if (isFirstTime) {
  // Show onboarding screens
  Navigator.pushNamed(context, '/onboarding');
} else {
  // Check if user has valid token
  if (hasValidToken) {
    Navigator.pushNamed(context, '/dashboard');
  } else {
    Navigator.pushNamed(context, '/login');
  }
}
```

### 2. Authentication Flow

#### Register New User
```dart
Future<Map<String, dynamic>> register(String username, String email, String password) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.apiBaseUrl}/auth/register/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': username,
      'email': email,
      'password': password,
    }),
  );
  
  final data = json.decode(response.body);
  
  if (data['success']) {
    // Save tokens
    await TokenStorage.saveTokens(
      data['tokens']['access'],
      data['tokens']['refresh']
    );
    
    // Navigate to dashboard
    if (data['next_step'] == 'dashboard') {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
  
  return data;
}
```

#### Login Existing User
```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.apiBaseUrl}/auth/login/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': email,
      'password': password,
    }),
  );
  
  final data = json.decode(response.body);
  
  if (data['success']) {
    await TokenStorage.saveTokens(
      data['tokens']['access'],
      data['tokens']['refresh']
    );
    
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
  
  return data;
}
```

### 3. Dashboard Data Loading

```dart
Future<Map<String, dynamic>> loadDashboard() async {
  final token = await TokenStorage.getAccessToken();
  
  final response = await http.get(
    Uri.parse('${ApiConfig.apiBaseUrl}/dashboard/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  return json.decode(response.body);
}
```

### 4. Drone Management

```dart
class DroneService {
  static Future<List<Drone>> getDrones({String? status, String? urgency}) async {
    final token = await TokenStorage.getAccessToken();
    
    String url = '${ApiConfig.apiBaseUrl}/drones/';
    List<String> params = [];
    
    if (status != null) params.add('status=$status');
    if (urgency != null) params.add('urgency=$urgency');
    
    if (params.isNotEmpty) {
      url += '?' + params.join('&');
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    final data = json.decode(response.body);
    return (data['drones'] as List)
        .map((drone) => Drone.fromJson(drone))
        .toList();
  }
  
  static Future<Drone> addDrone(Drone drone) async {
    final token = await TokenStorage.getAccessToken();
    
    final response = await http.post(
      Uri.parse('${ApiConfig.apiBaseUrl}/drones/add/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(drone.toJson()),
    );
    
    final data = json.decode(response.body);
    return Drone.fromJson(data['drone']);
  }
}
```

### 5. Fleet Status

```dart
Future<FleetStatus> getFleetStatus() async {
  final token = await TokenStorage.getAccessToken();
  
  final response = await http.get(
    Uri.parse('${ApiConfig.apiBaseUrl}/fleet/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  return FleetStatus.fromJson(json.decode(response.body));
}
```

### 6. Reports

```dart
Future<ReportData> getReports() async {
  final token = await TokenStorage.getAccessToken();
  
  final response = await http.get(
    Uri.parse('${ApiConfig.apiBaseUrl}/reports/overview/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  return ReportData.fromJson(json.decode(response.body));
}
```

## Data Models

### User Model
```dart
class User {
  final int id;
  final String username;
  final String email;
  final bool isFirstTime;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isFirstTime,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      isFirstTime: json['is_first_time'] ?? false,
    );
  }
}
```

### Drone Model
```dart
class Drone {
  final String id;
  final Location location;
  final Map<String, dynamic> packageDetails;
  final String urgencyLevel;
  final String? assignedPilot;
  final String additionalNote;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Drone({
    required this.id,
    required this.location,
    required this.packageDetails,
    required this.urgencyLevel,
    this.assignedPilot,
    required this.additionalNote,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Drone.fromJson(Map<String, dynamic> json) {
    return Drone(
      id: json['id'],
      location: Location.fromJson(json['location']),
      packageDetails: json['package_details'],
      urgencyLevel: json['urgency_level'],
      assignedPilot: json['assigned_pilot_name'],
      additionalNote: json['additional_note'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'location_latitude': location.latitude,
      'location_longitude': location.longitude,
      'package_details': packageDetails,
      'urgency_level': urgencyLevel,
      'additional_note': additionalNote,
      'status': status,
    };
  }
}

class Location {
  final double latitude;
  final double longitude;
  
  Location({required this.latitude, required this.longitude});
  
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
    );
  }
}
```

## Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message';
}

Future<T> handleApiResponse<T>(
  Future<http.Response> request,
  T Function(Map<String, dynamic>) parser,
) async {
  try {
    final response = await request;
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['success'] == false) {
        throw ApiException(data['message'] ?? 'Request failed');
      }
      return parser(data);
    } else {
      throw ApiException(
        data['message'] ?? 'Request failed',
        response.statusCode,
      );
    }
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException('Network error: $e');
  }
}
```

## Token Management

```dart
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
  
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
  
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
  
  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    // Check if token is expired (basic check)
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      
      return exp > now;
    } catch (e) {
      return false;
    }
  }
}
```

## Testing the Integration

1. Start the Django server:
```bash
cd backend
python manage.py runserver
```

2. Run the test script:
```bash
python test_api.py
```

3. In your Flutter app, test the endpoints:
```dart
void testApiIntegration() async {
  try {
    // Test health check
    final healthResponse = await http.get(Uri.parse('${ApiConfig.baseUrl}/'));
    print('Health: ${json.decode(healthResponse.body)}');
    
    // Test authentication
    final authData = await login('test@example.com', 'testpass123');
    print('Auth: $authData');
    
    // Test dashboard
    final dashboardData = await loadDashboard();
    print('Dashboard: $dashboardData');
    
  } catch (e) {
    print('Error: $e');
  }
}
```

## Production Considerations

1. **HTTPS**: Use HTTPS in production
2. **Token Refresh**: Implement automatic token refresh
3. **Error Handling**: Add comprehensive error handling
4. **Offline Support**: Cache data for offline usage
5. **Security**: Validate SSL certificates
6. **Performance**: Implement request caching and pagination