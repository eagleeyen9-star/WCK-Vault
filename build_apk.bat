@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not installed or not in PATH.
  echo Install Flutter and Android Studio first.
  pause
  exit /b 1
)
flutter create . --platforms=android --org com.noyon.wckvault --project-name wck_vault
if errorlevel 1 exit /b 1
flutter pub get
if errorlevel 1 exit /b 1
flutter build apk --release
if errorlevel 1 exit /b 1
echo.
echo APK created at:
echo build\app\outputs\flutter-apk\app-release.apk
pause
