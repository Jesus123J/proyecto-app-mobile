# Yata Wallet - Aplicación de Billetera Digital

Yata Wallet es una aplicación móvil de billetera digital desarrollada en Flutter que permite a los usuarios realizar transferencias de dinero, consultar su historial de movimientos y gestionar su saldo de forma segura.

## 📱 Características Principales

- ✅ **Registro de usuarios** con saldo inicial de S/ 100.00
- ✅ **Inicio de sesión** seguro con PIN de 4 dígitos
- ✅ **Transferencias de dinero** entre usuarios
- ✅ **Historial de movimientos** con filtros (Todos, Recibidos, Enviados)
- ✅ **Notificaciones en tiempo real** cuando recibes dinero
- ✅ **Consulta de datos de perfil** completos
- ✅ **Actualización automática del saldo** después de transferencias
- ✅ **Interfaz moderna** con Material Design 3

## 🔧 Requisitos del Sistema

### Versiones Requeridas

- **Flutter**: 3.32.4 o superior
- **Dart**: 3.8.1 o superior
- **Dart SDK**: ^3.8.1

### Plataformas Soportadas

- **Android**: API 21 (Android 5.0 Lollipop) o superior
- **iOS**: iOS 12.0 o superior

### Herramientas Necesarias

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) o [VS Code](https://code.visualstudio.com/)
- Un emulador de Android o dispositivo físico
- Git (para clonar el repositorio)

## 📦 Dependencias del Proyecto

### Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8              # Íconos de iOS
  get: ^4.6.6                          # Gestión de estado y navegación
  intl: ^0.19.0                        # Internacionalización y formato de fechas
  http: ^1.2.0                         # Peticiones HTTP
  get_storage: ^2.1.1                  # Almacenamiento local
  flutter_local_notifications: ^17.2.4 # Notificaciones locales
```

### Dependencias de Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0                # Linter de código
  flutter_launcher_icons: ^0.14.1      # Generador de íconos
```

## 🚀 Instalación y Configuración

### 1. Verificar Instalación de Flutter

Abre una terminal y ejecuta:

```bash
flutter --version
```

Deberías ver una salida similar a:
```
Flutter 3.32.4 • channel stable
Dart 3.8.1 • DevTools 2.45.1
```

Si no tienes Flutter instalado, sigue la [guía oficial de instalación](https://flutter.dev/docs/get-started/install).

### 2. Verificar Dispositivos Disponibles

```bash
flutter devices
```

Esto mostrará los dispositivos o emuladores disponibles para ejecutar la app.

### 3. Clonar o Descargar el Proyecto

Si usas Git:
```bash
git clone <url-del-repositorio>
cd app_yata
```

O simplemente navega a la carpeta del proyecto:
```bash
cd "C:\Users\Jesus Gutierrez\Documents\git project\app_android_kotlin\app_yata"
```

### 4. Instalar Dependencias

Ejecuta el siguiente comando en la raíz del proyecto:

```bash
flutter pub get
```

Este comando descargará e instalará todas las dependencias necesarias.

### 5. Verificar Configuración

Verifica que no haya problemas con la configuración:

```bash
flutter doctor
```

Resuelve cualquier problema marcado con ❌ antes de continuar.

## 🎨 Configurar Íconos de la App (Opcional)

Si deseas personalizar el ícono de la aplicación:

### 1. Preparar tu imagen

- Crea una imagen PNG de **1024x1024 píxeles**
- Guárdala como `assets/icon/app_icon_foreground.png`

### 2. Generar íconos

```bash
flutter pub run flutter_launcher_icons
```

Esto generará automáticamente todos los tamaños de íconos para Android e iOS.

## ▶️ Ejecutar la Aplicación

### Modo Debug (Desarrollo)

Para ejecutar la app en modo de desarrollo:

```bash
flutter run
```

Si tienes múltiples dispositivos, especifica cuál usar:

```bash
flutter run -d <device-id>
```

### Modo Release (Producción)

Para compilar una versión de producción:

#### Android (APK)

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

#### Android (App Bundle para Google Play)

```bash
flutter build appbundle --release
```

El bundle se generará en: `build/app/outputs/bundle/release/app-release.aab`

#### iOS

```bash
flutter build ios --release
```

## 🔑 Configuración de la API

La aplicación se conecta a la siguiente API:

```
Base URL: https://api.clinicagovision.com/api
API Token: sk_yata_b7c8d9e0f1g2h3i4
```

### Endpoints Utilizados

- `POST /usuarios` - Registro de usuarios
- `GET /auth/login/contacto/:contacto/:pin` - Inicio de sesión
- `PUT /externo/transferir` - Realizar transferencia
- `GET /usuarios/movimientos/:numerocelular` - Obtener movimientos
- `GET /externo/wallets/:numeroCelular` - Consultar wallets disponibles
- `GET /externo/transferir` - Obtener usuarios disponibles

## 📱 Permisos de Android

La aplicación requiere los siguientes permisos en Android (ya configurados en `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## 🎯 Uso de la Aplicación

### 1. Registro

1. Abre la app y presiona **"Regístrate aquí"**
2. Completa los siguientes datos:
   - **DNI**: 8 dígitos
   - **Nombre completo**
   - **Número de celular**: 9 dígitos
   - **PIN**: 4 dígitos
   - **Confirmar PIN**
3. Al registrarte recibirás **S/ 100.00** de saldo inicial
4. Serás redirigido al login automáticamente

### 2. Inicio de Sesión

1. Ingresa tu **número de celular** (9 dígitos)
2. Ingresa tu **PIN** (4 dígitos)
3. Presiona **"Iniciar Sesión"**

### 3. Dashboard

Una vez dentro, verás:
- Tu **saldo disponible**
- Botones de acción: **Enviar**, **Mi Perfil**, **Historial**
- Tus **últimos 3 movimientos**

### 4. Realizar Transferencia

1. Presiona el botón **"Enviar"**
2. Ingresa el **número de destino** (9 dígitos)
3. Espera a que se carguen las billeteras disponibles
4. Ingresa el **monto** a transferir
5. Agrega un **mensaje** (opcional)
6. Ingresa tu **PIN** para confirmar
7. Presiona **"Transferir"**

### 5. Ver Historial

1. Presiona el botón **"Historial"**
2. Usa los filtros para ver:
   - **Todos** los movimientos
   - Solo los **Recibidos**
   - Solo los **Enviados**
3. Arrastra hacia abajo para **refrescar**

### 6. Ver Mis Datos

1. Presiona el botón **"Mi Perfil"**
2. Se mostrará un modal con tu información completa:
   - DNI
   - Nombre completo
   - Número de celular
   - Saldo actual
   - Correo electrónico (si está registrado)

## 🔔 Notificaciones

La app incluye notificaciones automáticas:

- **Monitoreo cada 5 segundos** cuando estás en sesión
- **Notificación instantánea** cuando recibes dinero
- Formato: *"¡Ya te llegó el dinero! Recibiste S/ XX.XX"*
- Las notificaciones incluyen el **mensaje** de la transferencia

## 🗂️ Estructura del Proyecto

```
lib/
├── controllers/          # Controladores de GetX
│   ├── dashboard_controller.dart
│   ├── login_controller.dart
│   ├── register_controller.dart
│   ├── historial_controller.dart
│   └── enviar_controller.dart
├── models/              # Modelos de datos
│   ├── movimiento.dart
│   ├── usuario.dart
│   ├── wallet.dart
│   └── transaccion.dart
├── services/            # Servicios y lógica de negocio
│   ├── api_service.dart
│   └── notification_service.dart
├── views/               # Pantallas de la app
│   ├── login/
│   ├── register/
│   ├── dashboard/
│   ├── historial/
│   └── enviar/
├── routes/              # Configuración de rutas
│   ├── app_routes.dart
│   └── app_pages.dart
└── main.dart            # Punto de entrada
```

## 🐛 Solución de Problemas

### Error: "Waiting for another flutter command to release the startup lock"

```bash
# Windows
del C:\Users\<TuUsuario>\AppData\Local\Temp\flutter_tools\lockfile

# Luego ejecuta
flutter clean
flutter pub get
```

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error de permisos en Android

Asegúrate de que:
1. Los permisos estén en `android/app/src/main/AndroidManifest.xml`
2. Para Android 13+, acepta manualmente los permisos de notificación

### La app no compila

```bash
# Limpia todo y reinstala
flutter clean
flutter pub get
flutter pub upgrade
```

## 📊 Versión de la App

- **Versión actual**: 1.0.0+1
- **Última actualización**: Noviembre 2025

## 👨‍💻 Desarrollo

### Comandos Útiles

```bash
# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar con hot reload
flutter run --hot

# Generar APK de release
flutter build apk --release

# Analizar el código
flutter analyze

# Formatear el código
flutter format .

# Ver logs
flutter logs
```

### Actualizar Dependencias

```bash
# Ver dependencias desactualizadas
flutter pub outdated

# Actualizar a las últimas versiones compatibles
flutter pub upgrade

# Actualizar a las últimas versiones (incluso con breaking changes)
flutter pub upgrade --major-versions
```

## 📄 Licencia

Este proyecto es privado y no está disponible para publicación pública.

## 📞 Soporte

Para reportar problemas o solicitar características:
- Crear un issue en el repositorio
- Contactar al equipo de desarrollo

---

**Desarrollado con Flutter 💙**
