import 'package:cloud_firestore/cloud_firestore.dart';

class PagoYape {
  final String id;
  final String nombre;
  final String monto;
  final String mensaje;
  final String fecha;
  final String hora;
  final DateTime timestamp;

  PagoYape({
    this.id = '',
    required this.nombre,
    required this.monto,
    required this.mensaje,
    required this.fecha,
    required this.hora,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'monto': monto,
      'mensaje': mensaje,
      'fecha': fecha,
      'hora': hora,
      'timestamp': FieldValue.serverTimestamp(),
      'monto_num': double.tryParse(monto.replaceAll(',', '')) ?? 0.0,
    };
  }

  factory PagoYape.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PagoYape(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      monto: data['monto'] ?? '0.00',
      mensaje: data['mensaje'] ?? '',
      fecha: data['fecha'] ?? '',
      hora: data['hora'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
