import 'package:flutter/material.dart';
import '../models/pago_yape.dart';

class UltimoPagoCard extends StatelessWidget {
  final PagoYape pago;

  const UltimoPagoCard({super.key, required this.pago});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE8FFF6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF00C896), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ÚLTIMO PAGO RECIBIDO",
              style: TextStyle(
                color: Color(0xFF00C896),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pago.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "S/ ${pago.monto}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C3FC5),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  pago.fecha,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  "·",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  pago.hora,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const Spacer(),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00C896),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
