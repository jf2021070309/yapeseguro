const String APP_VERSION    = '1.0.0';
const String PACKAGE_YAPE   = 'com.bcp.innovacxion.yapeapp';
const String PREFIJO_PERU   = '+51';

// Regex para extraer monto del texto de la notificación ((?i) lo hace insensible a mayúsculas/minúsculas)
const String REGEX_MONTO  = r'(?i)s[/\s\.]*([\d]+[.,]?\d*)';

// Regex para extraer nombre del pagador
// Ejemplo: "Juan Pérez te yapeo S/ 50.00"
const String REGEX_NOMBRE = r'(?i)^(.+?)\s+te\s+(yapeo|envió|yapeó)';

// Colección en Firestore
const String FIRESTORE_COLECCION = 'pagos_yape';

// Paquetes a monitorear (agregar Plin u otros aquí)
const List<String> PAQUETES_MONITOREAR = [
  'com.bcp.innovacxion.yapeapp', // ID Oficial de Yape
  'pe.yape.app', // Alternativo/Obsoleto
  // 'pe.bcp.plin',
  
  // -- AÑADIDOS PARA PRUEBAS (Puedes borrarlos luego) --
  'com.whatsapp', // WhatsApp normal
  'com.whatsapp.w4b', // WhatsApp Business
  'org.telegram.messenger', // Telegram
];
