# 🔐 Seguridad de API Key - Gemini

## ⚠️ PROBLEMA ACTUAL

Tu API key está **expuesta públicamente** en el código:
```gdscript
var api_key = "AIzaSyBvjf2jcp_tVENdWBXFY6FWo5Vvc8YTtcY"
```

**Consecuencias:**
- ✅ Cualquier persona que abra la consola del navegador puede verla
- ✅ Pueden copiar tu key y usarla para sus propios proyectos
- ✅ Puedes agotar tu cuota gratuita rápidamente
- ✅ En caso de tier pago, podrían generar costos no autorizados

---

## 🛡️ SOLUCIONES

### Opción 1: Regenerar la API Key (RECOMENDADO)

1. Ve a [Google AI Studio](https://aistudio.google.com/app/apikey)
2. **Elimina la key actual**: `AIzaSyBvjf2jcp_tVENdWBXFY6FWo5Vvc8YTtcY`
3. Crea una nueva API key
4. Reemplázala en `Mundo.gd`
5. **NO SUBAS** el archivo con la key al repositorio público

### Opción 2: Usar Variables de Entorno (Solo para Desktop)

```gdscript
# En Mundo.gd
var api_key = OS.get_environment("GEMINI_API_KEY")

if api_key == "":
    print("⚠️ GEMINI_API_KEY no encontrada en variables de entorno")
    api_key = "TU_KEY_TEMPORAL_AQUI"
```

**Nota:** Esto NO funciona en Web Export (la key seguirá visible en el código compilado).

### Opción 3: Backend Proxy (LA MÁS SEGURA para Web)

Crea un servidor intermedio que oculte tu key:

```python
# backend.py (Python + Flask)
from flask import Flask, request, jsonify
import requests
import os

app = Flask(__name__)
API_KEY = os.environ['GEMINI_API_KEY']  # Key segura en servidor

@app.route('/api/gemini', methods=['POST'])
def proxy_gemini():
    data = request.json
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent"
    headers = {'Content-Type': 'application/json'}
    params = {'key': API_KEY}  # Key nunca se envía al cliente
    
    response = requests.post(url, headers=headers, params=params, json=data)
    return jsonify(response.json()), response.status_code

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Luego en `Mundo.gd`:
```gdscript
var api_url = "https://tu-servidor.com/api/gemini"  # Sin ?key=
```

### Opción 4: Dejar que el Usuario Configure su Propia Key

```gdscript
# En _ready()
func _ready():
    if FileAccess.file_exists("user://gemini_key.txt"):
        var file = FileAccess.open("user://gemini_key.txt", FileAccess.READ)
        api_key = file.get_as_text().strip_edges()
        file.close()
    else:
        show_api_key_configuration_dialog()
```

---

## 📊 Límites de la API (Tier Gratuito)

- **15 peticiones por minuto (RPM)**
- **1,500 peticiones por día (RPD)**
- **1 millón de tokens por día**

**El código actual YA implementa rate limiting** para respetar estos límites:
- ✅ Espera mínimo 4.5 segundos entre peticiones
- ✅ Sistema de cola para peticiones múltiples
- ✅ Reintentos automáticos con backoff exponencial
- ✅ Mensajes de feedback al usuario

---

## 🚀 Tier Pago (Si necesitas más)

Si necesitas hacer más de 15 peticiones por minuto:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Habilita facturación
3. Activa Gemini API
4. Límites aumentan a:
   - **1,000 RPM**
   - **4 millones tokens/día**

**Costo aproximado:** $0.00015 por 1K tokens (muy económico para uso moderado)

---

## ✅ Estado Actual

Después de los cambios implementados:

- ✅ **Rate limiting activo** (4.5s entre peticiones)
- ✅ **Sistema de cola** para peticiones múltiples
- ✅ **Manejo de error 429** con reintentos automáticos
- ✅ **Feedback al usuario** durante esperas
- ⚠️ **API key aún expuesta** - Considera regenerarla y usar proxy

---

## 📝 Próximos Pasos Recomendados

1. **Regenera tu API key inmediatamente**
2. **No subas la nueva key al repositorio**
3. **Considera implementar un backend proxy** para deployments web
4. **Documenta en README** que los usuarios necesitan su propia key
