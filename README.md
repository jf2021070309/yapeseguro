# YapeVerifica

YapeVerifica es una aplicación móvil desarrollada en **Flutter** diseñada para monitorear, registrar y notificar automáticamente los pagos recibidos a través de la aplicación Yape (Billetera digital del BCP, Perú).

## 🚀 ¿Cómo funciona?

El funcionamiento principal de la aplicación se basa en la interceptación inteligente de las notificaciones del sistema de Android, actuando en tiempo real:

1. **Monitoreo de Notificaciones:** La aplicación utiliza el paquete `flutter_notification_listener` para mantenerse escuchando todas las notificaciones entrantes de tu dispositivo. Puede funcionar tanto con la app abierta como en segundo plano.
2. **Filtro y Detección Exclusiva (Yape):** Cuando detecta una notificación proveniente de la app de Yape (cuyo paquete es `pe.yape.app`), captura el contenido de ese mensaje específico, ignorando las demás notificaciones del dispositivo para cuidar tu privacidad.
3. **Extracción de Datos de Pago:** Mediante el uso de Expresiones Regulares (RegEx), la aplicación analiza el texto de la notificación para extraer automáticamente la información clave:
   - **Nombre del Pagador** (ej. "Juan Pérez te yapeo...")
   - **Monto** transferido (ej. "S/ 50.00")
4. **Registro en la Nube (Firebase):** Inmediatamente después de extraer los datos exitosamente, la aplicación se conecta a Internet para guardar el registro de este pago en una base de datos en la nube usando **Firebase Cloud Firestore**, en una colección denominada `pagos_yape`. 
5. **Notificación SMS de Confirmación (Opcional):** Si configuraste un número de teléfono en la app, se envía de forma silenciosa un mensaje de texto (SMS) automático a ese número para confirmar la recepción del pago al instante. Esto es muy útil, por ejemplo, para notificar a empleados o socios de un negocio en otra ubicación de que el dinero ya llegó.
6. **Interfaz de Usuario (UI):** La pantalla principal muestra un resumen visual de las ventas del día y detalla el último pago recibido en tiempo real, todo presentado con un diseño al estilo Yape (color morado característico).

## 🛠️ Tecnologías y Paquetes Principales

*   **Flutter & Dart:** Framework principal de desarrollo de la app.
*   **Firebase Core & Cloud Firestore:** Almacenamiento de base de datos en tiempo real en la nube.
*   **flutter_notification_listener:** Lectura e intercepción de notificaciones del ecosistema de Android en segundo plano.
*   **telephony:** Para el envío en segundo plano de mensajes SMS automáticos sin intervención del usuario.
*   **shared_preferences:** Para el almacenamiento persistente de la configuración local en el dispositivo.

## ⚙️ Configuración y Pruebas (Guía Paso a Paso)

Para probar la aplicación y ver cómo los pagos se guardan automáticamente en la base de datos, sigue estas instrucciones:

### Paso 1: Configurar Firebase (Base de Datos)
La aplicación necesita un lugar donde guardar los datos. Usaremos Firebase de Google, que es gratuito:

1. Ve a [Firebase Console](https://console.firebase.google.com) e inicia sesión con una cuenta de Google.
2. Haz clic en **"Crear un proyecto"** (puedes llamarlo `yape-verifica`).
3. En el panel lateral, ve a **"Compilación" > "Firestore Database"** y haz clic en **Crear base de datos**.
4. Selecciona comenzar en **Modo de prueba** (esto permite leer y escribir datos libremente durante el desarrollo) y elige cualquier ubicación.
5. Vuelve a la página principal del proyecto de Firebase y haz clic en el ícono de **Android** para agregar una aplicación.
6. En "Nombre del paquete de Android", pon exactamente lo que dice tu archivo `android/app/build.gradle` (usualmente cerca de `applicationId`, por ejemplo: `com.example.flutter_application_4`). Los demás campos son opcionales.
7. **Descarga el archivo `google-services.json`** y arrástralo a la carpeta `android/app/` dentro de este proyecto de Flutter.

### Paso 2: Permisos en el Teléfono
Para que la app funcione, debes instalarla en un teléfono Android real (los emuladores no siempre reciben notificaciones correctamente):

1. Conecta tu teléfono por USB y ejecuta la app desde tu editor (`flutter run`).
2. La primera vez que abras la aplicación, te pedirá **Permiso para leer notificaciones**. Debes aceptar este permiso y buscar la app "YapeVerifica" en la lista de tu teléfono para concederle el acceso (esto le permite "escuchar" la llegada de Yapes).
3. Si activas la opción de enviar SMS, también te pedirá permiso para enviar mensajes.

### Paso 3: ¿Cómo Probar los Yapeos?
Tienes dos formas de probar que funciona y que los datos se guardan en Firebase:

**Opción A: La forma real (Recomendada)**
1. Ten instalada tu aplicación "YapeVerifica" en tu teléfono principal (el teléfono que tiene instalada tu cuenta de Yape).
2. Pídele a un amigo que te yapee 1 sol de prueba.
3. Cuando la notificación original de Yape aparezca en tu pantalla, tu aplicación "YapeVerifica" la detectará en menos de medio segundo.
4. Entra a Firebase Console > Firestore Database, y verás que mágicamente apareció una nueva colección llamada `pagos_yape` con el nombre de tu amigo y el monto.

**Opción B: La forma simulada (Sin gastar dinero)**
Si todavía no quieres usar Yape real, puedes simular una notificación usando una app externa.
1. Descarga alguna aplicación de la Play Store para "Simular Notificaciones" (busca "Test Notification" o "Notification Tester").
2. Crea una notificación falsa poniendo como nombre de aplicación/paquete: `pe.yape.app` (¡Esto es muy importante! Si no tiene este ID, YapeVerifica la ignorará).
3. Como texto de la notificación escribe exactamente este formato: `Juan Perez te yapeó S/ 10.50`
4. Lanza la notificación de prueba. Tu app la atrapará, extraerá a "Juan Perez" y "10.50", y lo subirá a Firebase.
