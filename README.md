# Flutter Django Full Stack Mobile App

A full-stack mobile application built with Flutter frontend and Django REST API backend.

## Tech Stack

**Frontend:**
- Flutter (Dart)
- HTTP package for API calls
- Provider/Bloc for state management

**Backend:**
- Django
- Django REST Framework
- SQLite/PostgreSQL database

## Project Structure

```
project/
├── flutter_app/          # Flutter mobile app
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── django_backend/       # Django API server
│   ├── manage.py
│   ├── requirements.txt
│   └── apps/
└── README.md
```

## Prerequisites

- Flutter SDK (3.0+)
- Python (3.8+)
- Django (4.0+)
- Android Studio/VS Code
- Git

## Setup Instructions

### Backend Setup (Django)

1. Navigate to backend directory:
```bash
cd django_backend
```

2. Create virtual environment:
```bash
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

5. Create superuser:
```bash
python manage.py createsuperuser
```

6. Start development server:
```bash
python manage.py runserver
```

### Frontend Setup (Flutter)

1. Navigate to Flutter directory:
```bash
cd flutter_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## API Endpoints

- `GET /api/` - API root
- `POST /api/auth/login/` - User login
- `POST /api/auth/register/` - User registration
- `GET /api/data/` - Get data
- `POST /api/data/` - Create data

## Features

- User authentication
- CRUD operations
- Real-time data sync
- Responsive UI
- Cross-platform support

## Development

### Running Tests

**Django:**
```bash
python manage.py test
```

**Flutter:**
```bash
flutter test
```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Configuration

1. Update API base URL in Flutter app
2. Configure Django settings for production
3. Set up environment variables
4. Configure database settings

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## Contact

For questions or support, contact Nexo