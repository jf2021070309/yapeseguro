import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/pago_yape.dart';
import '../config.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Guardar pago en Firestore
  Future<String> guardarPago(PagoYape pago) async {
    try {
      DocumentReference docRef = await _db.collection(FIRESTORE_COLECCION).add(pago.toFirestore());
      return docRef.id;
    } catch (e) {
      print("Error al guardar en Firestore: $e");
      rethrow;
    }
  }

  // 2. Stream para escuchar pagos de hoy
  Stream<List<PagoYape>> escucharPagosHoy() {
    String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    return _db
        .collection(FIRESTORE_COLECCION)
        .where('fecha', isEqualTo: fechaHoy)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => PagoYape.fromFirestore(doc)).toList();
        });
  }

  // 3. Resumen del día
  Future<Map<String, dynamic>> resumenDia() async {
    try {
      String fechaHoy = DateFormat('dd/MM/yyyy').format(DateTime.now());
      QuerySnapshot snapshot = await _db
          .collection(FIRESTORE_COLECCION)
          .where('fecha', isEqualTo: fechaHoy)
          .get();

      double total = 0.0;
      List<PagoYape> pagos = [];

      for (var doc in snapshot.docs) {
        PagoYape pago = PagoYape.fromFirestore(doc);
        pagos.add(pago);
        total += double.tryParse(pago.monto.replaceAll(',', '')) ?? 0.0;
      }

      // Ordenar de más reciente a más antiguo
      pagos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return {
        'cantidad': pagos.length,
        'total': total,
        'pagos': pagos,
      };
    } catch (e) {
      print("Error al obtener resumen: $e");
      return {
        'cantidad': 0,
        'total': 0.0,
        'pagos': [],
      };
    }
  }

  // 4. Obtener todos los pagos (Historial)
  Future<List<PagoYape>> obtenerHistorialTodos() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(FIRESTORE_COLECCION)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => PagoYape.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error al obtener historial: $e");
      return [];
    }
  }

  // 5. Escuchar todos los pagos en tiempo real (Historial en Vivo)
  Stream<List<PagoYape>> escucharHistorialTodos() {
    return _db
        .collection(FIRESTORE_COLECCION)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => PagoYape.fromFirestore(doc)).toList();
        });
  }
}
