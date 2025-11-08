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

# --- NUEVO: referencia al AssetManager ---
@onready var asset_manager = $AssetManager

var spawned_assets: Array = []

# NUEVO: Contador de instancias por asset
var asset_spawn_count = {}

# NUEVO: Límites de spawneo por asset (cuántos máximo se pueden crear)
var asset_spawn_limits = {
	"valvula": 1,     
	"fresadora": 1,
	"chiller": 1,    
	"llave": 5,        
}

#  NUEVO: Posiciones y rotaciones fijas para assets específicos
#TODO: BORRAR ESTO PARA QUE SEA MAS DINAMICO Y NO ESTE TAN HARDCODED
var fixed_positions = {
	"valvula": {
		"position": Vector3(0.657, 0.05, 0.96),
		"rotation": Vector3(0, 0, 0)
	},
	"fresadora": {
		"position": Vector3(-2.759, -1.027, -2.221),
		"rotation": Vector3(0, -180, 0)  # Y rotado -180 grados
	},
	"chiller": {
		"position": Vector3(3.811, -1.755, -6.491),
		"rotation": Vector3(0, 90, 0) 	
	}
}


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
	system_prompt += "\n\nIMPORTANTE:\n" \
		+ "Cuando el usuario pida insertar, agregar, crear o mostrar un objeto 3D, " \
		+ "debes responder SOLO en formato JSON, sin texto adicional, con las siguientes claves:\n" \
		+ "{ \"action\": \"insert\", \"asset\": \"<nombre_del_asset>\" }\n" \
		+ "Ejemplo: {\"action\":\"insert\",\"asset\":\"fresadora\"}"


# --- 2. FUNCIÓN MODIFICADA ---
func _on_text_submitted(text):
	rich_text_label.text += "\n[color=lightblue]Tú:[/color] " + text
	line_edit.text = ""

	# Detectar si hay que hacer captura
	var needs_screenshot = false
	var text_lower = text.to_lower()
	if "ver" in text_lower or "captura" in text_lower or "mira" in text_lower or "observa" in text_lower or "qué ves" in text_lower or "que ves" in text_lower:
		needs_screenshot = true
		rich_text_label.text += "\n[color=yellow]📸 Capturando pantalla...[/color]"

	rich_text_label.text += "\n[color=orange]Bot:[/color] Pensando..."

	if needs_screenshot:
		await take_screenshot()

	# Construir el mensaje del usuario
	var user_parts = []
	if needs_screenshot and screenshot_data != "":
		user_parts.append({
			"inline_data": {
				"mime_type": "image/png",
				"data": screenshot_data
			}
		})
	user_parts.append({"text": text})

	var body = {
		"system_instruction": {"parts": [{"text": system_prompt}]},
		"contents": [{"role": "user", "parts": user_parts}]
	}

	# --- 🔥 NUEVO BLOQUE: decidir si pedir JSON o texto ---
	var force_json = false
	var keywords = ["insertar", "crear", "agregar", "mostrar", "colocar", "poner"]
	for word in keywords:
		if word in text_lower:
			force_json = true
			break

	if force_json:
		body["generation_config"] = {"response_mime_type": "application/json"}
	else:
		body["generation_config"] = {"response_mime_type": "text/plain"}

	var body_json = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]

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
		rich_text_label.text += "\n[color=red]Error:[/color] No se pudo conectar. Código: " + str(response_code)
		print("Error de API: ", body.get_string_from_utf8())
		return

	var response_text = body.get_string_from_utf8()
	var json_data = JSON.parse_string(response_text)

	if json_data == null:
		rich_text_label.text += "\n[color=red]Error:[/color] Respuesta inválida del servidor."
		print("Respuesta inválida: ", response_text)
		return

	if json_data.get("candidates") and json_data.candidates[0].get("content"):
		var bot_response = json_data.candidates[0].content.parts[0].text
		print("🧠 Respuesta cruda de Gemini:\n", bot_response)

		# Intentar parsear JSON si la respuesta del bot es estructurada
		var parsed = {}
		var clean_response = bot_response.strip_edges()

		# Buscar un bloque JSON dentro de la respuesta aunque tenga texto adicional
		var json_start = clean_response.find("{")
		var json_end = clean_response.rfind("}")
		if json_start != -1 and json_end != -1:
			var json_substring = clean_response.substr(json_start, json_end - json_start + 1)
			var parsed_json = JSON.parse_string(json_substring)
			if typeof(parsed_json) == TYPE_DICTIONARY:
				parsed = parsed_json


		# Si contiene 'action', interpretamos como comando
		if parsed.has("action"):
			handleBotAction(parsed)
			return
		else:
			# Si no hay acción, mostramos texto normal
			rich_text_label.text += "\n[color=orange]Bot:[/color] " + bot_response
	else:
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

# --- NUEVO: manejar acciones del bot ---
func handleBotAction(parsed: Dictionary):
	print("handleBotAction")
	if parsed.has("action") and parsed.action == "insert":
		var asset_name = parsed.get("asset", "")
		if asset_name != "":
			insertAsset(asset_name)
		else:
			print("No se indicó asset")
			rich_text_label.text += "\n[color=red]Error:[/color] No se indicó asset."
	elif parsed.has("action") and parsed.action == "say":
		var msg = parsed.get("asset", "ok")
		rich_text_label.text += "\n[color=orange]Bot:[/color] " + msg
	else:
		rich_text_label.text += "\n[color=red]Error:[/color] Acción desconocida."


# --- NUEVO: insertar asset en el mundo ---
func insertAsset(name: String):
	print("insertAsset")
	var asset_key = name.to_lower()
	
	#  VERIFICAR SI EL ASSET TIENE LÍMITE DE SPAWNEO
	if asset_spawn_limits.has(asset_key):
		var current_count = asset_spawn_count.get(asset_key, 0)
		var max_limit = asset_spawn_limits[asset_key]
		
		if current_count >= max_limit:
			# Ya se alcanzó el límite
			var msg = "No se puede crear otro/a '" + name + "'. Ya existe " + str(current_count) + " en la escena (máximo: " + str(max_limit) + ")."
			rich_text_label.text += "\n[color=red]Error:[/color] " + msg
			print(msg)
			return  # ← Salir sin crear el asset
	
	var scene = asset_manager.getAsset(name)
	if scene == null:
		rich_text_label.text += "\n[color=red]Error:[/color] No se encontró el asset '" + name + "'."
		return
	
	var instance = scene.instantiate()
	instance.name = name + "_" + str(Time.get_ticks_msec())
	
	#  VERIFICAR SI EL ASSET TIENE POSICIÓN FIJA
	if fixed_positions.has(asset_key):
		# Usar posición y rotación fijas
		var fixed_data = fixed_positions[asset_key]
		instance.global_transform.origin = fixed_data.position
		
		# Aplicar rotación (convertir de grados a radianes)
		instance.rotation_degrees = fixed_data.rotation
		
		print("Asset '", name, "' colocado en posición fija: ", fixed_data.position)
		rich_text_label.text += "\n[color=green]Sistema:[/color] Se insertó " + name + " en posición fija."
	else:
		# Posición dinámica 
		instance.scale = Vector3(2, 2, 2)

		# --- Posición frente a cámara ---
		var cam_transform = camera.global_transform
		var forward = -cam_transform.basis.z.normalized()
		var start_pos = cam_transform.origin + forward * 3.0 + Vector3(0, 2.0, 0)

		# --- Buscar el piso con raycast ---
		var space = get_world_3d().direct_space_state
		var ray_params = PhysicsRayQueryParameters3D.create(start_pos, start_pos + Vector3(0, -20, 0))
		var ray_result = space.intersect_ray(ray_params)

		if ray_result.size() > 0:
			var ground_pos = ray_result.position
			var free_pos = findFreeSpot(ground_pos, 1.5)  # ← ahora es por distancia
			instance.global_transform.origin = free_pos
		else:
			instance.global_transform.origin = start_pos + Vector3(0, -1.0, 0)

	# --- Iniciar animación automáticamente  de los assets ---
	var anim_player = findAnimationPlayerInNode(instance)
	if anim_player:
		# Opción 1: Reproducir animación específica
		if anim_player.has_animation("Fresadora_TodoJunto"):
			anim_player.play("Fresadora_TodoJunto")
			print("Animación 'Fresadora_TodoJunto' iniciada")
		# Opción 2: Reproducir la primera animación disponible
		elif anim_player.get_animation_list().size() > 0:
			var first_anim = anim_player.get_animation_list()[0]
			anim_player.play(first_anim)
			print("Animación '", first_anim, "' iniciada")

	get_tree().current_scene.add_child(instance)
	spawned_assets.append(instance)
	rich_text_label.text += "\n[color=green]Sistema:[/color] Se insertó " + name + " en " + str(instance.global_transform.origin)
	
	# INCREMENTAR EL CONTADOR DE ASSET GENERADO
	if asset_spawn_count.has(asset_key):
		asset_spawn_count[asset_key] += 1
	else:
		asset_spawn_count[asset_key] = 1

# --- para animacion de los elementos ---
func findAnimationPlayerInNode(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var result = findAnimationPlayerInNode(child)
		if result:
			return result
	
	return null

## --- NUEVO: heurística simple para encontrar espacio libre ---
#func findFreePosition() -> Vector3:
	#var space = get_world_3d().direct_space_state
	#for i in range(20):
		#var pos = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
		#var box_size = Vector3(0.5, 0.5, 0.5)
		#var result = space.intersect_box(Transform3D(Basis(), pos), box_size, [], 1)
		#if result.size() == 0:
			#return pos
	#return Vector3(0, 0, 0)
	
func findFreeSpot(base_pos: Vector3, min_distance: float = 1.5, max_attempts: int = 40) -> Vector3:
	# Distribución en anillos: intenta posiciones alrededor del punto base,
	# aumentando radio si no encuentra hueco. Sin física, solo distancia.
	var ring_step := 0.6
	var angle_step := 18.0 # grados
	var radius := 0.0

	for attempt in range(max_attempts):
		if attempt % int(360.0 / angle_step) == 0:
			radius += ring_step

		var angle_deg = float(attempt % int(360.0 / angle_step)) * angle_step
		var angle = deg_to_rad(angle_deg)
		var offset = Vector3(cos(angle), 0, sin(angle)) * radius
		var test_pos = base_pos + offset

		var libre := true
		for n in spawned_assets:
			if n and n.is_inside_tree():
				if test_pos.distance_to(n.global_transform.origin) < min_distance:
					libre = false
					break
		if libre:
			return test_pos

	# Si no encontró nada “perfecto”, usa el base_pos
	return base_pos
