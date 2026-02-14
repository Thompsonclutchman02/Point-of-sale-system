# CARTGO - Inventory & Sales Management System

CARTGO is a comprehensive inventory and sales management application built with Flutter and FastAPI, designed for small to medium-sized businesses to manage products, sales, and employees efficiently.

## Features

- 📦 **Inventory Management** - Track products, stock levels, and low stock alerts
- 💰 **Sales Processing** - Handle transactions and sales history
- 👥 **Employee Management** - Manage staff accounts and permissions (Admin only)
- 📊 **Reports & Analytics** - View sales reports and product performance (Admin only)
- 🛒 **Point of Sale** - Process customer transactions quickly
- 📱 **Cross-Platform** - Works on Android devices

## Prerequisites

Before running the application, ensure you have the following installed:

### Backend Requirements
- Python 3.8+
- FastAPI
- Uvicorn
- PostgreSQL (or your preferred database)
- Required Python packages (check `requirements.txt` in backend)

### Frontend Requirements
- Flutter SDK (3.0+)
- Android Studio (for Android development)
- Java JDK 11+
- Physical Android device or emulator

## Project Structure

```
cartgo_app/
├── lib/
│   ├── screens/          # Flutter UI screens
│   ├── services/         # API services and authentication
│   ├── models/           # Data models
│   └── main.dart         # Application entry point
├── backend/              # FastAPI server
│   ├── main.py          # FastAPI application
│   ├── models.py        # Database models
│   └── requirements.txt # Python dependencies
└── android/             # Android-specific files
```

## Installation & Setup

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up your database:**
   - Configure database connection in `main.py`
   - Run database migrations if required

4. **Start the FastAPI server:**
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```
   
   **Important:** Use `--host 0.0.0.0` to allow connections from other devices.

5. **Verify backend is running:**
   - Open `http://localhost:8000/docs` in your browser
   - You should see the FastAPI Swagger documentation

### Frontend Setup

1. **Navigate to Flutter project root:**
   ```bash
   cd cartgo_app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API base URL:**
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` with your PC's IP address:
   ```dart
   static const String baseUrl = 'http://YOUR_PC_IP:8000';
   ```

4. **Get your PC's IP address:**
   - **Windows:** Run `ipconfig` and look for "IPv4 Address"
   - **Mac/Linux:** Run `ifconfig` or `ip addr show`

## Running the Application

### Development Mode

1. **Start the backend server** (in backend directory):
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

2. **Run Flutter app** (in project root):
   ```bash
   flutter run
   ```

### Testing Network Connection

1. **Test backend from your phone:**
   - Open `http://YOUR_PC_IP:8000/docs` in your phone's browser
   - If you see the API docs, the connection is working

2. **Common connection issues:**
   - Ensure both devices are on the same WiFi network
   - Check firewall settings on your PC
   - Verify the IP address in `api_service.dart`

## Building APK

### Build Release APK

1. **Clean previous builds:**
   ```bash
   flutter clean
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build APK:**
   ```bash
   flutter build apk --release
   ```

4. **Find the APK:**
   - Location: `build/app/outputs/flutter-apk/app-release.apk`

### Install APK on Device

1. **Method 1 - Direct install:**
   ```bash
   flutter install
   ```

2. **Method 2 - Manual install:**
   - Transfer `app-release.apk` to your Android device
   - Enable "Install from unknown sources" in settings
   - Open the APK file and install

## User Accounts

### Default Admin Account
- **Username:** `admin`
- **Password:** `admin123` (or as configured in your backend)

### Employee Accounts
- Can be created by administrators through the Employee Management section
- Employees have access to basic features but cannot access admin sections

## Admin Features

Administrators have access to:
- Employee management
- System reports and analytics
- All inventory and sales functions

## Troubleshooting

### Common Issues

1. **Connection refused errors:**
   - Verify backend server is running
   - Check IP address in `api_service.dart`
   - Ensure devices are on same network

2. **Firewall blocking connection:**
   ```bash
   # Windows - allow port 8000
   netsh advfirewall firewall add rule name="FastAPI Port 8000" dir=in action=allow protocol=TCP localport=8000
   ```

3. **Build failures:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

4. **Database connection issues:**
   - Verify database server is running
   - Check connection strings in backend
   - Ensure database tables are created

### Debug Mode

To enable debug mode (shows debug banner):
- Remove or set to true: `debugShowCheckedModeBanner: true` in `main.dart`

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are installed
3. Ensure both backend and frontend are properly configured
4. Check network connectivity between devices

## License

This project is licensed for internal use. Contact the development team for more information.

---

**Note:** This application is designed for internal business use. Ensure proper security measures are in place when deploying in production environments.

## Quick Start Scripts

### Backend Startup Script (Windows - save as `start_backend.bat`)
```batch
@echo off
echo Starting CARTGO Backend Server...
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
```

### Flutter Run Script (Windows - save as `start_flutter.bat`)
```batch
@echo off
echo Starting CARTGO Flutter App...
flutter clean
flutter pub get
flutter run
pause
```

### APK Build Script (Windows - save as `build_apk.bat`)
```batch
@echo off
echo Building CARTGO APK...
flutter clean
flutter pub get
flutter build apk --release
echo APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
pause
```

**Version:** 1.0.0  
**Last Updated:** 2024
