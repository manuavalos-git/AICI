# 🏭 Simulador Industrial 3D con IA

Simulador educativo de entornos industriales con asistente de IA integrado para aprendizaje de equipamiento y procesos industriales.

## 🎯 Características

### Asistente de IA Industrial
- **Visión por computadora**: La IA puede ver lo que estás viendo en el simulador
- **Instructor especializado**: Enseña sobre herramientas, maquinaria y equipos industriales
- **Conocimiento técnico**: Explica funcionamiento, aplicaciones, seguridad y mantenimiento
- **Interactivo**: Responde preguntas y muestra objetos 3D bajo demanda

### Entorno 3D
- **Free Camera**: Movimiento libre por la fábrica/almacén
- **Assets 3D**: Herramientas y equipos visualizables en 3D
- **Chat flotante**: Interfaz de chat movible y escalable
- **Controles intuitivos**: WASD + Mouse para navegación

## 🎮 Controles

### Cámara (Free Cam)
- **WASD**: Mover (adelante/atrás/izquierda/derecha)
- **Mouse**: Mirar alrededor
- **Espacio**: Subir (eje Y)
- **Shift**: Bajar (eje Y)
- **CTRL**: Activar/Desactivar controles de cámara

### Chat de IA
- **T**: Minimizar/Maximizar ventana de chat
- **Click + Arrastrar**: Mover el chat en el espacio 3D
- **Rueda del Mouse**: Zoom in/out del chat
- **Click en campo de texto**: Escribir mensaje

## 💬 Comandos del Chat

### Comandos de Visión
Usa estas palabras para que la IA vea tu pantalla:
- "ver" - "¿qué ves?"
- "captura" - "mira esto"
- "observa" - "analiza"

Ejemplo: *"Mira lo que estoy viendo, ¿qué es esto?"*

### Comandos de Invocación (Futuro)
- `mostrar [objeto]` - Invocar un asset 3D
- Ejemplo: *"mostrar llave inglesa"*

### Preguntas Educativas
- "¿Cómo funciona una bomba centrífuga?"
- "¿Para qué sirve una llave dinamométrica?"
- "¿Qué EPP necesito para trabajar con maquinaria?"
- "Explícame los tipos de válvulas industriales"

## 🛠️ Sistema de Assets

### Assets Actuales
- ✅ Llave (toggle con acción `toggle_sprite`)
- ✅ Warehouse/Fábrica (entorno)

### Assets Planificados
Ver `assets_catalog.md` para el catálogo completo

## 📋 Archivos del Sistema

### Configuración de IA
- `system_prompt_industrial.md` - Instrucciones del comportamiento de la IA
- `assets_catalog.md` - Catálogo de objetos 3D disponibles

### Scripts Principales
- `Mundo.gd` - Controlador principal del simulador
- `CameraController.gd` - Sistema de cámara libre
- `ChatUI.gd` - Interfaz del chat

### Escenas
- `Mundo.tscn` - Escena principal
- `ChatUI.tscn` - UI del chat
- `scenery/warehouse_fbx.fbx` - Modelo de la fábrica

## 🔧 Configuración de la API

### Requisitos
- API Key de Google AI Studio (Gemini)
- Modelo: `gemini-2.0-flash-exp` (soporta visión)

### Configurar API Key
Edita `Mundo.gd` línea ~22:
```gdscript
var api_key = "TU_API_KEY_AQUI"
```

## 📚 Flujo de Uso Típico

1. **Inicio**: El asistente te saluda y explica sus capacidades
2. **Exploración**: Muévete por la fábrica con WASD
3. **Consulta visual**: Escribe "ver" para que la IA analice lo que ves
4. **Aprendizaje**: Haz preguntas sobre equipamiento industrial
5. **Práctica**: (Futuro) Invoca objetos 3D para estudiarlos

## 🎓 Casos de Uso Educativos

### Estudiantes
- Aprender identificación de herramientas
- Comprender principios de funcionamiento
- Estudiar normas de seguridad

### Profesionales
- Repasar procedimientos
- Consultar especificaciones técnicas
- Entrenamiento en nuevos equipos

### Instructores
- Demostrar equipos en 3D
- Explicar conceptos con soporte visual
- Evaluar conocimiento de estudiantes

## 🚀 Mejoras Futuras

### Sistema de Assets
- [ ] Implementar diccionario de assets cargables
- [ ] Sistema de spawn dinámico
- [ ] Categorías de objetos (herramientas, maquinaria, EPP, etc.)

### IA
- [ ] Historial de conversación persistente
- [ ] Modo quiz/evaluación
- [ ] Generación de informes de aprendizaje

### Interacción
- [ ] Manipulación de objetos (rotar, escalar)
- [ ] Anotaciones en 3D
- [ ] Mediciones y comparaciones

### Contenido
- [ ] Más modelos 3D industriales
- [ ] Animaciones de funcionamiento
- [ ] Simulaciones de procesos

## 📝 Notas Técnicas

### Captura de Pantalla
- Se toma automáticamente cuando detecta palabras clave
- Convierte a PNG y codifica en base64
- Envía junto con el mensaje a Gemini Vision

### System Prompt
- Carga desde `system_prompt_industrial.md`
- Se incluye en cada llamada a la API
- Define el comportamiento y conocimiento de la IA

### Gemini API
- Usa `system_instruction` para contexto persistente
- Soporta multimodal (texto + imagen)
- Rate limit: según tu plan de Google AI

## ⚠️ Limitaciones Actuales

- Solo un asset (llave) implementado completamente
- No hay sistema de spawn dinámico aún
- Historial de conversación no se mantiene entre mensajes
- No hay persistencia de datos

## 🤝 Contribuir

Para agregar nuevos assets industriales:
1. Importa el modelo 3D a `scenery/`
2. Crea la escena .tscn
3. Actualiza `assets_catalog.md`
4. Implementa la lógica de spawn en `Mundo.gd`
5. Actualiza `system_prompt_industrial.md` con info del nuevo asset

## 📄 Licencia

Proyecto educativo - Uso libre para aprendizaje

---

**Desarrollado con Godot 4.x + Gemini AI**
