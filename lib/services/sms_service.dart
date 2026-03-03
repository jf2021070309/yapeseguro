import 'package:telephony/telephony.dart';
import '../models/pago_yape.dart';
import '../config.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<int> enviarSMSATodos(PagoYape pago, List<String> numeros) async {
    int enviados = 0;
    
    // Filtrar números: no vacíos y exactamente 9 dígitos
    List<String> numerosValidos = numeros
        .where((n) => n.trim().length == 9 && int.tryParse(n.trim()) != null)
        .toList();

    for (String numero in numerosValidos) {
      try {
        String numFinal = numero.startsWith('9') ? '$PREFIJO_PERU$numero' : numero;
        
        String mensaje = "✅ YAPE RECIBIDO\n"
            "Monto: S/ ${pago.monto}\n"
            "De: ${pago.nombre}\n"
            "Hora: ${pago.hora}\n"
            "Fecha: ${pago.fecha}";

        await telephony.sendSms(
          to: numFinal,
          message: mensaje,
        );
        enviados++;
      } catch (e) {
        print("Error enviando SMS a $numero: $e");
      }
    }
    
    return enviados;
  }
}
