# 🔑 Configuración de API Key de OpenAI

## 📋 Pasos para Obtener tu API Key

1. **Ve a OpenAI Platform:**
   https://platform.openai.com/api-keys

2. **Crea una cuenta** (si no tienes una)
   - Es gratis para empezar
   - Recibes $5 de crédito gratis para probar

3. **Genera una nueva API key:**
   - Click en "Create new secret key"
   - Copia la key completa (empieza con `sk-proj-...`)

4. **Configura la key en el simulador:**
   - En el chat del simulador, escribe:
   ```
   /setkey sk-proj-tu-key-aqui
   ```
   - Reemplaza `sk-proj-tu-key-aqui` con tu key real

## ✅ Verificación

Si todo funciona correctamente, verás:
```
✅ API key configurada correctamente!
```

## 🔒 Seguridad

- Tu API key se guarda **localmente en tu navegador** (localStorage)
- **NO** se envía a ningún servidor excepto OpenAI
- Puedes eliminarla en cualquier momento con: `/clearkey`

## 💰 Costos

- **Texto**: ~$0.0002 por mensaje
- **Con imagen**: ~$0.004 por mensaje (captura de pantalla)
- Los $5 gratis te dan ~1,250 mensajes con captura

## 🆘 Comandos Disponibles

- `/setkey <tu-key>` - Configurar API key
- `/clearkey` - Eliminar API key guardada

## 🐛 Solución de Problemas

### Error 401 (Unauthorized)
- Tu API key es inválida o fue revocada
- Genera una nueva en https://platform.openai.com/api-keys

### Error 429 (Rate Limit)
- Has excedido el límite de peticiones
- Espera unos segundos e intenta de nuevo

### "No hay API key configurada"
- Usa el comando `/setkey` con tu key de OpenAI
