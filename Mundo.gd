extends Node3D

# --- TUS VARIABLES ---
@export var line_edit: LineEdit
@export var rich_text_label: RichTextLabel
@export var sub_viewport_node: SubViewport

# ¡NUEVA VARIABLE!
@export var gemini_request: HTTPRequest
@onready var sprite = $Sprite3D
@onready var camera = $Camera3D

var isVisible = false

# --- NUEVO: referencia al AssetManager ---
@onready var asset_manager = $AssetManager

# ¡TU API KEY! (Conseguila en Google AI Studio)
var api_key = "AIzaSyB2uzFzx1TzUn138iq_8BYVtrEHgvikSNQ"

# La URL de la API de Gemini
var api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=" + api_key

# --- NUEVO: prompt del sistema ---
var system_prompt = """
Eres un asistente dentro de un mundo 3D de Godot VR.
Si el usuario pide insertar o agregar un objeto, responde SOLO en JSON con los campos:
action ('insert' o 'say') y asset (nombre del objeto o texto a decir).
Ejemplo: {"action":"insert","asset":"silla"} o {"action":"say","asset":"ok"}.
No uses texto fuera del JSON.
"""

var spawned_assets: Array = []

# NUEVO: Contador de instancias por asset
var asset_spawn_count = {}

# NUEVO: Límites de spawneo por asset (cuántos máximo se pueden crear)
var asset_spawn_limits = {
	"valvula": 1,     
	"fresadora": 1,    
	"llave": 5,        
}

#  NUEVO: Posiciones y rotaciones fijas para assets específicos
var fixed_positions = {
	"valvula": {
		"position": Vector3(0.657, 0.05, 0.96),
		"rotation": Vector3(0, 0, 0)
	},
	"fresadora": {
		"position": Vector3(-1.909, -1.027, -2.221),
		"rotation": Vector3(0, -180, 0)  # Y rotado -180 grados
	}
}

func _ready():
	line_edit.text_submitted.connect(_on_text_submitted)
	gemini_request.request_completed.connect(_on_request_completed)
	sprite.visible = false

# --- 2. FUNCIÓN MODIFICADA ---
func _on_text_submitted(text):
	rich_text_label.text += "\n[color=lightblue]Tú:[/color] " + text
	line_edit.text = ""
	rich_text_label.text += "\n[color=orange]Bot:[/color] Pensando..."

	# --- NUEVO: incluimos el prompt del sistema ---
	var body = {
		"contents": [
			{
				"role": "user",
				"parts": [
					{
						"text": system_prompt + "\n\nUsuario: " + text
					}
				]
			}
		]
	}


	
	var body_json = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]

	gemini_request.request(api_url, headers, HTTPClient.METHOD_POST, body_json)


# --- 3. FUNCIÓN MODIFICADA ---
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		rich_text_label.text += "\n[color=red]Error:[/color] No se pudo conectar. Código: " + str(response_code)
		print("Error de API: ", body.get_string_from_utf8())
		return

	var response_text = body.get_string_from_utf8()
	var json_data = JSON.parse_string(response_text)
	
	if json_data.get("candidates") and json_data.candidates[0].get("content"):
		var bot_response = json_data.candidates[0].content.parts[0].text.strip_edges()
		print("Respuesta de Gemini:", bot_response)
		
		var parsed_text = bot_response.strip_edges()

		# eliminar bloques tipo ```json ... ``` si los hay
		if parsed_text.begins_with("```"):
			parsed_text = parsed_text.replace("```json", "")
			parsed_text = parsed_text.replace("```", "")
			parsed_text = parsed_text.strip_edges()

		print("Intentando parsear:", parsed_text)

		var parsed = JSON.parse_string(parsed_text)
		if typeof(parsed) == TYPE_DICTIONARY:
			handleBotAction(parsed)
		else:
			# --- NUEVO: fallback al modo charla normal ---
			print("No se detectó acción. Buscando respuesta general en Gemini...")
			askGeminiGeneral(bot_response)
	else:
		rich_text_label.text += "\n[color=red]Error:[/color] Respuesta vacía o bloqueada."
		print("Respuesta vacía o bloqueada: ", response_text)


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

# --- TU FUNCIÓN DE INPUT (idéntica) ---
func _input(event):
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
		
	if event.is_action_pressed("toggle_sprite"):
		isVisible = !isVisible
		sprite.visible = isVisible
		if isVisible:
			snapChatInFrontOfCamera()

func snapChatInFrontOfCamera() -> void:
	var cam_t: Transform3D = camera.global_transform
	var forward: Vector3 = -cam_t.basis.z.normalized() # dirección “hacia adelante” de la cámara
	var distance: float = 0.5                          # cuán lejos del jugador
	var height: float = 0.0                            # 0 => misma altura de la cámara

	# posición directamente enfrente
	var pos: Vector3 = cam_t.origin + forward * distance + Vector3(0, height, 0)
	sprite.global_position = pos

	# orientación mirando a la cámara
	sprite.look_at(cam_t.origin, Vector3.UP)
	sprite.rotate_y(deg_to_rad(180))                   # corrige la inversión

func askGeminiGeneral(user_text: String) -> void:
	var body := {
		"contents": [{
			"role": "user",
			"parts": [{"text": user_text}]
		}]
	}

	var headers := ["Content-Type: application/json"]
	var url: String = api_url

	rich_text_label.text += "\n[color=orange]Bot:[/color] Buscando información general..."
	gemini_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
