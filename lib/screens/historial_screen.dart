import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pago_yape.dart';
import '../services/firebase_service.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<PagoYape> _todosPagos = [];
  List<PagoYape> _pagosFiltrados = [];
  bool _isLoading = true;
  StreamSubscription<List<PagoYape>>? _pagosSub;
  
  String _filtroTiempo = 'Todos'; // Todos, Hoy, Semana, Mes
  String _busquedaTexto = '';

  @override
  void initState() {
    super.initState();
    _iniciarEscucha();
  }

  void _iniciarEscucha() {
    setState(() => _isLoading = true);
    _pagosSub = _firebaseService.escucharHistorialTodos().listen((listaPagos) {
      if (mounted) {
        _todosPagos = listaPagos;
        _aplicarFiltros();
      }
    });
  }

  @override
  void dispose() {
    _pagosSub?.cancel();
    super.dispose();
  }

  void _aplicarFiltros() {
    List<PagoYape> resultado = List.from(_todosPagos);

    // 1. Filtro de Tiempo
    DateTime ahora = DateTime.now();
    if (_filtroTiempo == 'Hoy') {
      resultado = resultado.where((p) {
        return p.timestamp.year == ahora.year && 
               p.timestamp.month == ahora.month && 
               p.timestamp.day == ahora.day;
      }).toList();
    } else if (_filtroTiempo == 'Semana') {
      // Tomamos últimos 7 días
      DateTime haceUnaSemana = ahora.subtract(const Duration(days: 7));
      resultado = resultado.where((p) => p.timestamp.isAfter(haceUnaSemana)).toList();
    } else if (_filtroTiempo == 'Mes') {
      resultado = resultado.where((p) {
        return p.timestamp.year == ahora.year && p.timestamp.month == ahora.month;
      }).toList();
    }

    // 2. Filtro de Texto (Nombre)
    if (_busquedaTexto.isNotEmpty) {
      resultado = resultado.where((p) {
        return p.nombre.toLowerCase().contains(_busquedaTexto.toLowerCase());
      }).toList();
    }

    setState(() {
      _pagosFiltrados = resultado;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos suma total de filtrados
    double sumaTotal = 0;
    for (var p in _pagosFiltrados) {
      sumaTotal += double.tryParse(p.monto.replaceAll(',', '')) ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial Completo"),
        backgroundColor: const Color(0xFF6C3FC5),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // FILTROS
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Buscador por nombre
                TextField(
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre o frase...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (val) {
                    _busquedaTexto = val;
                    _aplicarFiltros();
                  },
                ),
                const SizedBox(height: 12),
                // Chips de tiempo
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Hoy', 'Semana', 'Mes'].map((filtro) {
                      bool isSelected = _filtroTiempo == filtro;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _filtroTiempo = filtro;
                                _aplicarFiltros();
                              });
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          selectedColor: const Color(0xFF6C3FC5).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF6C3FC5) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // SUMA RESUMEN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${_pagosFiltrados.length} pagos mostrados",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total: S/ ${sumaTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Color(0xFF6C3FC5), 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // LISTA
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _pagosFiltrados.isEmpty 
                ? const Center(child: Text("No hay pagos que coincidan con los filtros."))
                : ListView.builder(
                    itemCount: _pagosFiltrados.length,
                    itemBuilder: (context, index) {
                      final pago = _pagosFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black12)
                        ),
                        color: Colors.white,
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFF0E7FF),
                            child: Icon(Icons.person, color: Color(0xFF6C3FC5)),
                          ),
                          title: Text(
                            pago.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${pago.fecha} · ${pago.hora}", style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                            "S/ ${pago.monto}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00C896),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
