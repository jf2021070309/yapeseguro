import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pago_yape.dart';
import '../config.dart';
import 'firebase_service.dart';
import 'sms_service.dart';

class YapeService {
  final FirebaseService _firebaseService = FirebaseService();
  final SmsService _smsService = SmsService();

  Future<PagoYape?> procesarNotificacion(NotificationEvent event) async {
    // 1. Solo procesar si el paquete está en PAQUETES_MONITOREAR
    if (!PAQUETES_MONITOREAR.contains(event.packageName)) return null;

    final String title = event.title ?? "";
    final String text = event.text ?? "";
    final String fullText = "$title - $text";

    // 2. Extraer monto
    final RegExp regExpMonto = RegExp(REGEX_MONTO);
    final Match? matchMonto = regExpMonto.firstMatch(fullText);
    String monto = matchMonto?.group(1) ?? "0.00";

    // 3. Extraer nombre
    final RegExp regExpNombre = RegExp(REGEX_NOMBRE);
    final Match? matchNombre = regExpNombre.firstMatch(
      text,
    ); // Usualmente el nombre está al inicio del texto
    String nombre =
        matchNombre?.group(1) ?? (title.isNotEmpty ? title : "Usuario Yape");

    // 4. Capturar tiempo
    DateTime ahora = DateTime.now();
    String fecha = DateFormat('dd/MM/yyyy').format(ahora);
    String hora = DateFormat('hh:mm:ss a').format(ahora);

    // 5. Crear objeto PagoYape
    PagoYape pago = PagoYape(
      nombre: nombre,
      monto: monto,
      mensaje: fullText,
      fecha: fecha,
      hora: hora,
      timestamp: ahora,
    );

    try {
      // 6. Obtener números de SharedPreferences para SMS
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> numeros = [
        prefs.getString('tel1') ?? '',
        prefs.getString('tel2') ?? '',
        prefs.getString('tel3') ?? '',
      ];

      // 7. Ejecutar en paralelo: Guardar en Firebase y enviar SMS
      await Future.wait([
        _firebaseService.guardarPago(pago),
        _smsService.enviarSMSATodos(pago, numeros),
      ]);

      return pago;
    } catch (e) {
      print("Error en procesarNotificacion: $e");
      return pago; // Retornar el pago de todas formas para actualizar UI local
    }
  }
}
