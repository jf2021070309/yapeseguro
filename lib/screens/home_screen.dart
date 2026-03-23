import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:firebase_core/firebase_core.dart';

import '../config.dart';
import '../models/pago_yape.dart';
import '../services/yape_service.dart';
import '../services/firebase_service.dart';
import '../widgets/ultimo_pago_card.dart';
import '../widgets/configuracion_card.dart';
import '../widgets/resumen_dia_sheet.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool servicioActivo = false;
  int contadorSesion = 0;
  PagoYape? ultimoPago;

  final List<TextEditingController> _telControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final YapeService _yapeService = YapeService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _cargarConfiguracion();

    // 1. Notifications Listener Permission
    bool hasPermission = await NotificationsListener.hasPermission ?? false;
    if (!hasPermission) {
      _showPermissionDialog();
    } else {
      _startMonitoring();
    }
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _telControllers[0].text = prefs.getString('tel1') ?? '';
        _telControllers[1].text = prefs.getString('tel2') ?? '';
        _telControllers[2].text = prefs.getString('tel3') ?? '';
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Permiso Requerido"),
        content: const Text(
          "YapeVerifica necesita acceso a notificaciones para detectar "
          "pagos de Yape automáticamente y guardarlos en Firebase. "
          "Activa 'YapeVerifica' en la siguiente pantalla.",
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await NotificationsListener.openPermissionSettings();
              // Check again after coming back
            },
            child: const Text("DAR PERMISO"),
          ),
        ],
      ),
    );
  }

  void _startMonitoring() async {
    await NotificationsListener.startService(
      foreground: true,
      title: "YapeVerifica activo",
      description: "Guardando pagos en Firebase automáticamente",
    );

    setState(() {
      servicioActivo = true;
    });

    NotificationsListener.receivePort?.listen((event) async {
      final pago = await _yapeService.procesarNotificacion(event);
      if (pago != null) {
        if (mounted) {
          setState(() {
            contadorSesion++;
            ultimoPago = pago;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Pago guardado en Firebase: S/ ${pago.monto}'),
              backgroundColor: const Color(0xFF00C896),
            ),
          );
        }
      }
    });
  }

  Future<void> _openFirebase() async {
    final Uri url = Uri.parse("https://console.firebase.google.com");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _showResumen() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FutureBuilder<Map<String, dynamic>>(
        future: _firebaseService.resumenDia(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text("Error al cargar resumen")),
            );
          }
          return ResumenDiaSheet(resumen: snapshot.data!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C3FC5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "YapeVerifica",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 24),

              // CARD: ESTADO DEL SERVICIO
              _buildEstadoCard(),
              const SizedBox(height: 20),

              // CARD: ACCIONES
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openFirebase,
                      icon: const Icon(Icons.cloud),
                      label: const Text("FIREBASE"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showResumen,
                      icon: const Icon(Icons.bar_chart),
                      label: const Text("RESUMEN"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistorialScreen()),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text("HISTORIAL COMPLETO"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFF6C3FC5),
                    side: const BorderSide(color: Color(0xFF6C3FC5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CARD: ÚLTIMO PAGO
              if (ultimoPago != null) ...[
                UltimoPagoCard(pago: ultimoPago!),
                const SizedBox(height: 20),
              ],

              // CARD: CONFIGURACIÓN
              ConfiguracionCard(controllers: _telControllers, onSaved: () {}),

              const SizedBox(height: 32),

              // FOOTER
              Center(
                child: Column(
                  children: [
                    Text(
                      "YapeVerifica v$APP_VERSION · Firebase",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("¿Necesitas ayuda?"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: servicioActivo ? const Color(0xFF00C896) : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        servicioActivo ? "✅ Activo" : "❌ Inactivo",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEstadoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: servicioActivo ? const Color(0xFF00C896) : Colors.red,
              width: 5,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monitoreando pagos de Yape en tiempo real",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Notificaciones detectadas esta sesión: $contadorSesion",
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            if (ultimoPago != null)
              Text(
                "Último pago: ${ultimoPago!.fecha} ${ultimoPago!.hora}",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.cloud_sync, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                  "Sincronizando con Firebase",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
