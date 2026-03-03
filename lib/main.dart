import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Removido por estar sin uso en main.dart

import 'screens/home_screen.dart';
import 'services/yape_service.dart';

/*
  SETUP FIREBASE:
  1. Ir a https://console.firebase.google.com
  2. Crear proyecto "yape-verifica"
  3. Agregar app Android con package name de la app (pe.yape.verifica o el que definas)
  4. Descargar google-services.json y colocarlo en android/app/
  5. En Firestore → Crear base de datos → Modo producción
  6. Reglas de Firestore para desarrollo:
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /pagos_yape/{doc} {
           allow read, write: if true;
         }
       }
     }
  7. Ejecutar: flutterfire configure (opcional si usas google-services.json manual)
*/

@pragma('vm:entry-point')
void notificationCallback(NotificationEvent event) {
  print("Notificación recibida en segundo plano: ${event.packageName}");
  YapeService().procesarNotificacion(event);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print(
      "Error inicializando Firebase (asegúrate de incluir google-services.json): $e",
    );
  }

  // Inicializar Notification Listener
  NotificationsListener.initialize(callbackHandle: notificationCallback);

  runApp(const YapeVerificaApp());
}

class YapeVerificaApp extends StatelessWidget {
  const YapeVerificaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YapeVerifica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C3FC5), // Morado Yape
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        fontFamily: 'Roboto', // O Inter si prefieres
      ),
      home: const HomeScreen(),
    );
  }
}
