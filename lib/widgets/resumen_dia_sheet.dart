import 'package:flutter/material.dart';
import '../models/pago_yape.dart';

class ResumenDiaSheet extends StatelessWidget {
  final Map<String, dynamic> resumen;

  const ResumenDiaSheet({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final List<PagoYape> pagos = resumen['pagos'] as List<PagoYape>;
    final double total = resumen['total'] as double;
    final int cantidad = resumen['cantidad'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Resumen del Día",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                "Total Pagos",
                cantidad.toString(),
                Icons.receipt_long_outlined,
              ),
              _buildStat(
                "Suma Total",
                "S/ ${total.toStringAsFixed(2)}",
                Icons.payments_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Últimos 5 pagos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          if (pagos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No hay pagos registrados hoy")),
            )
          else
            ...pagos
                .take(5)
                .map(
                  (pago) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0E7FF),
                      child: Icon(Icons.person, color: Color(0xFF6C3FC5)),
                    ),
                    title: Text(
                      pago.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${pago.fecha} · ${pago.hora}"),
                    trailing: Text(
                      "S/ ${pago.monto}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C3FC5),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6C3FC5)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
