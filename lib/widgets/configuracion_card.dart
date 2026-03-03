import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracionCard extends StatefulWidget {
  final List<TextEditingController> controllers;
  final VoidCallback onSaved;

  const ConfiguracionCard({
    super.key,
    required this.controllers,
    required this.onSaved,
  });

  @override
  State<ConfiguracionCard> createState() => _ConfiguracionCardState();
}

class _ConfiguracionCardState extends State<ConfiguracionCard> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tel1', widget.controllers[0].text);
      await prefs.setString('tel2', widget.controllers[1].text);
      await prefs.setString('tel3', widget.controllers[2].text);
      
      widget.onSaved();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Configuración guardada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings, color: Color(0xFF6C3FC5)),
                  SizedBox(width: 8),
                  Text(
                    "Configuración de Notificaciones",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                "Números para Notificación SMS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C3FC5),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: widget.controllers[index],
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    decoration: InputDecoration(
                      prefixText: "+51 ",
                      prefixStyle: const TextStyle(color: Colors.grey),
                      hintText: index == 0 
                          ? "Teléfono principal" 
                          : "Teléfono ${index + 1} (Opcional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (index == 0 && (value == null || value.isEmpty)) {
                        return "El teléfono principal es requerido";
                      }
                      if (value != null && value.isNotEmpty && value.length != 9) {
                        return "Debe tener exactamente 9 dígitos";
                      }
                      return null;
                    },
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3FC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "GUARDAR CONFIGURACIÓN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
