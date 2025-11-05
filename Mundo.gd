extends Node3D

# --- TUS VARIABLES ---
@export var line_edit: LineEdit
@export var rich_text_label: RichTextLabel
@export var sub_viewport_node: SubViewport
@export var chat_ui: Control  # Nueva referencia al ChatUI

# ¡NUEVA VARIABLE!
@export var gemini_request: HTTPRequest
@onready var sprite = $Sprite3D
@onready var camera = $Camera3D
@onready var camera_controller = $Camera3D  # Referencia al script de la cámara

var isVisible = false
var is_dragging_chat = false
var drag_start_pos = Vector2.ZERO

# Sistema de instrucciones y visión
var system_prompt = ""
var conversation_history = []
var screenshot_data = ""

# ¡TU API KEY! (Conseguila en Google AI Studio)
var api_key = "AIzaSyDwgIreZnegfT7JnY6b91_lHVIOK4RW0WI"

# La URL de la API de Gemini Vision (2.0 flash soporta imágenes)
var api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=" + api_key

func _ready():
	# Cargar el system prompt desde el archivo
	load_system_prompt()
	
	# 1. Conectar la UI (esto ya lo tenías)
	line_edit.text_submitted.connect(_on_text_submitted)
	
	# Conectar señales de focus del LineEdit
	line_edit.focus_entered.connect(_on_line_edit_focus_entered)
	line_edit.focus_exited.connect(_on_line_edit_focus_exited)
	
	# 2. ¡NUEVA CONEXIÓN!
	# Conectamos la señal de "request_completed" del nodo HTTPRequest
	# a una nueva función que crearemos.
	gemini_request.request_completed.connect(_on_request_completed)
	
	# Mensaje de bienvenida
	rich_text_label.text = "[color=orange]🏭 Asistente Industrial:[/color] ¡Hola! Soy tu asistente de enseñanza industrial. Puedo ayudarte a aprender sobre herramientas, maquinaria y equipos industriales.\n\n💡 Comandos especiales:\n- Escribe 'ver' o 'captura' para que vea lo que estás viendo en el simulador\n- Pregúntame sobre cualquier herramienta o equipo industrial\n- Pídeme que te muestre objetos 3D\n\n¿En qué puedo ayudarte?"

func load_system_prompt():
	var file_path = "res://system_prompt_industrial.md"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		system_prompt = file.get_as_text()
		file.close()
		print("✅ System prompt cargado: ", system_prompt.length(), " caracteres")
	else:
		print("⚠️ No se encontró system_prompt_industrial.md, usando prompt básico")
		system_prompt = "Eres un asistente de enseñanza industrial especializado en equipamiento, herramientas y procesos industriales. Ayuda a los usuarios a aprender de manera clara y práctica."


# --- 2. FUNCIÓN MODIFICADA ---
func _on_text_submitted(text):
	# 1. Añadimos el texto del usuario al chat
	rich_text_label.text += "\n[color=lightblue]Tú:[/color] " + text
	
	# 2. Borramos el texto del LineEdit
	line_edit.text = ""
	
	# 3. Detectar si el usuario quiere que la IA vea el simulador
	var needs_screenshot = false
	var text_lower = text.to_lower()
	if "ver" in text_lower or "captura" in text_lower or "mira" in text_lower or "observa" in text_lower or "qué ves" in text_lower or "que ves" in text_lower:
		needs_screenshot = true
		rich_text_label.text += "\n[color=yellow]📸 Capturando pantalla...[/color]"
	
	# 4. Mostramos un mensaje de "Cargando..."
	rich_text_label.text += "\n[color=orange]Bot:[/color] Pensando..."
	
	# 5. Tomar captura si es necesario
	if needs_screenshot:
		await take_screenshot()
	
	# 6. Construir el historial de conversación
	var user_parts = []
	
	# Agregar captura si existe
	if needs_screenshot and screenshot_data != "":
		user_parts.append({
			"inline_data": {
				"mime_type": "image/png",
				"data": screenshot_data
			}
		})
	
	# Agregar el texto del usuario
	user_parts.append({"text": text})
	
	# 7. Preparamos el "cuerpo" (body) de la llamada a la API con system instruction
	var body = {
		"system_instruction": {
			"parts": [
				{"text": system_prompt}
			]
		},
		"contents": [
			{
				"role": "user",
				"parts": user_parts
			}
		]
	}
	
	# 8. Convertimos el body a texto JSON
	var body_json = JSON.stringify(body)
	
	# 9. Preparamos los headers (el tipo de contenido)
	var headers = ["Content-Type: application/json"]

	# 10. ¡HACEMOS LA LLAMADA!
	gemini_request.request(api_url, headers, HTTPClient.METHOD_POST, body_json)


# Función para tomar captura de pantalla
func take_screenshot():
	# Esperar un frame para asegurar que todo esté renderizado
	await get_tree().process_frame
	
	# Capturar la imagen del viewport
	var img = get_viewport().get_texture().get_image()
	
	# Convertir a PNG
	var png_data = img.save_png_to_buffer()
	
	# Convertir a base64 para enviar a la API
	screenshot_data = Marshalls.raw_to_base64(png_data)
	
	print("📸 Captura tomada: ", screenshot_data.length(), " caracteres en base64")


# --- 3. NUEVA FUNCIÓN ---
# Esta función se llama AUTOMÁTICAMENTE cuando la API responde
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		# Si algo salió mal (ej: API key incorrecta, sin internet)
		rich_text_label.text += "\n[color=red]Error:[/color] No se pudo conectar. Código: " + str(response_code)
		print("Error de API: ", body.get_string_from_utf8())
		return

	# 1. Convertimos la respuesta (que es un montón de bytes) a texto
	var response_text = body.get_string_from_utf8()
	
	# 2. Parseamos (leemos) el texto JSON
	var json_data = JSON.parse_string(response_text)
	
	# 3. Sacamos la respuesta de adentro del JSON
	#    (Esto puede fallar si la API te bloquea por seguridad)
	if json_data.get("candidates") and json_data.candidates[0].get("content"):
		var bot_response = json_data.candidates[0].content.parts[0].text
		
		# 4. ¡Mostramos la respuesta!
		# (Quizás tengas que borrar el "Pensando...")
		rich_text_label.text += "\n[color=orange]Bot:[/color] " + bot_response
	else:
		# Esto pasa si la API te da una respuesta OK (200) pero sin texto
		# (Usualmente por un filtro de seguridad)
		rich_text_label.text += "\n[color=red]Error:[/color] La API devolvió una respuesta vacía."
		print("Respuesta vacía o bloqueada: ", response_text)


# Funciones para manejar el focus del chat
func _on_line_edit_focus_entered():
	# Desactivar controles de cámara cuando se enfoca el chat
	if camera_controller and camera_controller.has_method("disable_movement"):
		camera_controller.disable_movement()
	print("Chat enfocado - Controles desactivados")

func _on_line_edit_focus_exited():
	# Reactivar controles cuando se desenfoca el chat
	if camera_controller and camera_controller.has_method("enable_movement"):
		camera_controller.enable_movement()
	print("Chat desenfocado - Controles reactivados")


func _input(event):
	# Zoom del chat con la rueda del mouse (solo cuando NO estás escribiendo)
	if event is InputEventMouseButton and not line_edit.has_focus():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Acercar el chat (aumentar escala)
			sprite.scale += Vector3(0.1, 0.1, 0.1)
			sprite.scale = sprite.scale.clamp(Vector3(0.5, 0.5, 0.5), Vector3(5.0, 5.0, 5.0))
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Alejar el chat (disminuir escala)
			sprite.scale -= Vector3(0.1, 0.1, 0.1)
			sprite.scale = sprite.scale.clamp(Vector3(0.5, 0.5, 0.5), Vector3(5.0, 5.0, 5.0))
			get_viewport().set_input_as_handled()
			return
	
	# Toggle chat con tecla T
	if event.is_action_pressed("ui_text_completion_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_T and not line_edit.has_focus()):
		if chat_ui and chat_ui.has_method("toggle_minimize"):
			chat_ui.toggle_minimize()
		get_viewport().set_input_as_handled()
		return
	
	# Manejar arrastre del chat en 3D (solo si NO está escribiendo)
	if not line_edit.has_focus():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Verificar si el click está sobre el chat (Sprite3D)
				var mouse_pos = get_viewport().get_mouse_position()
				
				# Si no hay colisión, verificar si está sobre el sprite visualmente
				var sprite_screen_pos = camera.unproject_position(sprite.global_transform.origin)
				var distance_to_sprite = mouse_pos.distance_to(sprite_screen_pos)
				
				# Si está cerca del sprite (dentro de un radio aproximado)
				if distance_to_sprite < 400:  # Radio de detección ajustable
					is_dragging_chat = true
					drag_start_pos = mouse_pos
					get_viewport().set_input_as_handled()
					return
			else:
				is_dragging_chat = false
		
		elif event is InputEventMouseMotion and is_dragging_chat:
			# Mover el sprite en el espacio 3D según el movimiento del mouse
			var mouse_pos = get_viewport().get_mouse_position()
			var delta_mouse = mouse_pos - drag_start_pos
			drag_start_pos = mouse_pos
			
			# Convertir movimiento 2D a movimiento 3D
			var cam_transform = camera.global_transform
			var right = cam_transform.basis.x
			var up = cam_transform.basis.y
			
			# Mover el sprite
			sprite.global_transform.origin += right * delta_mouse.x * 0.005
			sprite.global_transform.origin += -up * delta_mouse.y * 0.005
			
			get_viewport().set_input_as_handled()
			return
	else:
		# Si está escribiendo, detener cualquier arrastre
		is_dragging_chat = false
	
	if event.is_action_pressed("ui_focus_next"): 
		if line_edit.has_focus():
			line_edit.release_focus()
			print("Chat desenfocado")
		else:
			line_edit.grab_focus()
			print("Chat enfocado")
		get_viewport().set_input_as_handled()
	elif line_edit.has_focus():
		sub_viewport_node.push_input(event)
		get_viewport().set_input_as_handled()
		
	# Toggle sprite solo cuando NO estás escribiendo
	if event.is_action_pressed("toggle_sprite") and not line_edit.has_focus():
		isVisible = !isVisible
		sprite.visible = isVisible
		if isVisible:
			# Calculamos posición frente a la cámara
			var cam_transform = camera.global_transform
			sprite.global_transform.origin = cam_transform.origin + cam_transform.basis.z * -2.0
