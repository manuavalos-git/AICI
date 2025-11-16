# 🚀 Simulador Industrial 3D con IA

Aprendizaje técnico industrial en un entorno 3D + IA multimodal (visión + texto).

Este proyecto permite explorar un entorno industrial en 3D, invocar maquinaria/herramientas reales, y aprender gracias a un asistente de IA que ve la escena y responde preguntas en tiempo real.

## 🌐 Demo Online (GitHub Pages)

Simulador funcionando online:  
https://aiciorg.github.io/AICI/

(Funciona en navegador, requiere configurar tu API Key).

## ⚙️ GitHub Pages & GitHub Actions (PARA EL PRÓXIMO EQUIPO)

El repositorio incluye una configuración para desplegar automáticamente la versión web exportada de Godot en cada push a master.

### 🔄 ¿Cómo funciona?

Cada vez que se hace push a master:

- 🚀 GitHub Actions exporta el proyecto Godot a HTML5.
- 📤 Sube los archivos resultantes a la rama gh-pages.
- 🌎 GitHub Pages sirve esa rama como sitio web.

El workflow está en:  
.github/workflows/deploy-static.yml

### 🖥️ Godot Headless + Export Templates

El workflow utiliza Godot 4.x headless para realizar la exportación sin interfaz.

### 🔧 Cómo modificar el comportamiento del deploy

#### 🔀 Cambiar la rama que dispara el deploy

Editar en deploy-static.yml:

```

on:
push:
branches:
- master

```

Por ejemplo:

```

on:
push:
branches:
- main
- develop
- release

```

### 🐞 Problemas comunes con GitHub Pages

- 🔧 Ir a Settings → Pages → Source = Deploy from branch → gh-pages
- 📁 Confirmar que index.html existe en gh-pages
- 📝 Revisar errores en Actions

---

## 🔑 Configuración Inicial (IMPORTANTE)

Antes de usar el simulador necesitas tu API Key de OpenAI.

### Pasos:

- 🌐 Ir a https://platform.openai.com/api-keys
- 🆕 Crear cuenta (tiene crédito inicial)
- 🔐 Crear API Key

En el simulador escribir:

```

/setkey tu-key-aqui

```

La key se guarda en localStorage si estás en navegador.  
En escritorio podés usar la variable de entorno:

```

OPENAI_API_KEY=xxxx

```

Ver guía completa: API_KEY_SETUP.md

---

## 🛠️ ¿Qué puedes hacer?

- 🏭 Explorar una fábrica en 3D (FreeCam)
- 👀 Preguntar sobre lo que ves (visión automática)
- 📘 Recibir explicaciones técnicas con IA
- 🏗️ Invocar activos 3D industriales
- 📦 Insertar todos los activos disponibles
- 💬 Usar chat flotante 3D con zoom y arrastre
- 💾 Guardar tu API Key localmente

---

## 🎮 Controles

### 🎥 Cámara (FreeCam)

| Acción | Tecla |
|-------|-------|
| Mover | WASD |
| Mirar | Mouse |
| Subir | Espacio |
| Bajar | Shift |
| Activar/desactivar cámara | Ctrl |

### 💬 Chat

| Acción | Tecla |
|-------|-------|
| Minimizar/maximizar chat | T |
| Zoom del chat | Rueda del mouse |
| Arrastrar chat 3D | Click + arrastrar |
| Escribir mensaje | Click + teclado |

Cuando el chat tiene foco → la cámara se desactiva.

---

## 📚 Comandos del Chat

### 🔑 API Key

```

/setkey TU_KEY
/clearkey

```

### 🏗️ Insertar activos 3D

- "Muestra una fresadora"
- "Insertá una válvula"
- "Agregá un chiller"
- "Pon todos los equipos" (→ insertAllAssets)
- "Insertá válvula y chiller" (múltiples)

### 🎓 Preguntas educativas

- "¿Qué EPP necesito para operar una fresadora?"
- "Explicame tipos de válvulas industriales"
- "¿Qué máquinas aparecen en la escena?"

### 👁️ Visión automática

No hace falta pedir captura.  
La IA siempre ve tu pantalla.

---

## 🗂️ Sistema de Assets

### 📦 Activos Disponibles

- Válvula
- Fresadora
- Chiller
- Llave

(Se esperan más activos en futuras versiones.)

### 🔢 Límites

Definidos en asset_spawn_limits:

```

"valvula": 1,
"fresadora": 1,
"chiller": 1,
"llave": 5

```

### 📌 Posiciones fijas

Algunos activos se insertan en posiciones establecidas en:

```

fixed_positions

```

### ➕ Añadir un nuevo asset

- Importar modelo 3D a scenery/
- Crear .tscn
- Registrar en AssetManager
- Añadir a assets_catalog.md
- Agregar límite en asset_spawn_limits
- Añadir posición fija si corresponde
- Documentar en system_prompt_industrial.md

---

## 🤖 Funcionamiento Interno de IA

### 🧠 Modelo

GPT-4o 2024-08-06

### 📡 Endpoint

```

/v1/chat/completions

```

Internamente el sistema:

- 🖼️ Siempre envía captura PNG → base64
- 📘 Usa system_prompt_industrial.md
- 🔧 Soporta acciones JSON:

```

{"action":"insert","asset":"fresadora"}
{"action":"insert","asset":"all"}
{"action":"insert","assets":["valvula","chiller"]}

```

### ⚠️ Manejo de errores

- 429 → límite excedido
- 401 → API Key inválida
- Otros → mensaje de error en el chat

---

## 📁 Archivos Técnicos Importantes

### 📜 Scripts

- Mundo.gd → controlador principal
- ChatUI.gd → interfaz del chat
- CameraController.gd → cámara libre
- AssetManager.gd → gestión de assets

### ⚙️ Configuración

- system_prompt_industrial.md → instrucciones de la IA
- assets_catalog.md → catálogo de activos
- .github/workflows/deploy-static.yml → deploy automático

### 🎬 Escenas

- Mundo.tscn → escena principal
- ChatUI.tscn → chat UI
- assets/*.tscn → activos 3D

---

## 🧩 Para el Próximo Equipo de Desarrollo

### 🗂️ Estructura recomendada

```

scripts/     → lógica
assets/      → modelos 3D
scenes/      → escenas principales
ui/          → interfaz
addons/      → plugins

```

### 🚧 Workflow recomendado

- Crear ramas por feature (feature/spawn-chiller)
- Hacer PRs a master
- Verificar CI antes de mergear
- Documentar nuevos assets
- Actualizar README cuando cambie una funcionalidad

### 🧹 Buenas prácticas

- ❌ No subir claves API
- 🏷️ Mantener nombres coherentes en assets
- 🌍 Probar HTML5 antes de merge
- 🧼 Mantener .gitignore limpio
- 🧩 Mantener el formato JSON para IA:

```

{"action":"insert","asset":"nombre"}

```

---

## 🛣️ Roadmap / Mejoras Futuras

- Historial de conversación persistente
- Interacción avanzada con objetos 3D
- Más maquinaria industrial
- Animaciones de funcionamiento real
- Simulaciones de procesos industriales
- Modo quiz / evaluación

---

## 📜 Licencia

Proyecto educativo — uso libre para aprendizaje.

Hecho con Godot 4.x + OpenAI GPT-4o Vision  
Equipo AICI — 2025

Última actualización: [16/11/2025]
