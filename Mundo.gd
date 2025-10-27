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

# ¡TU API KEY! (Conseguila en Google AI Studio)
var api_key = "AIzaSyDwgIreZnegfT7JnY6b91_lHVIOK4RW0WI"

# La URL de la API de Gemini
var api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=" + api_key

func _ready():
	# 1. Conectar la UI (esto ya lo tenías)
	line_edit.text_submitted.connect(_on_text_submitted)
	
	# 2. ¡NUEVA CONEXIÓN!
	# Conectamos la señal de "request_completed" del nodo HTTPRequest
	# a una nueva función que crearemos.
	gemini_request.request_completed.connect(_on_request_completed)


# --- 2. FUNCIÓN MODIFICADA ---
func _on_text_submitted(text):
	# 1. Añadimos el texto del usuario al chat
	rich_text_label.text += "\n[color=lightblue]Tú:[/color] " + text
	
	# 2. Borramos el texto del LineEdit
	line_edit.text = ""
	
	# 3. Mostramos un mensaje de "Cargando..."
	rich_text_label.text += "\n[color=orange]Bot:[/color] Pensando..."

	# 4. Preparamos el "cuerpo" (body) de la llamada a la API
	#    (Este es el formato JSON que pide Gemini)
	var body = {
		"contents": [
			{
				"role": "user",
				"parts": [
					{"text": text}
				]
			}
		]
	}
	
	# 5. Convertimos el body a texto JSON
	var body_json = JSON.stringify(body)
	
	# 6. Preparamos los headers (el tipo de contenido)
	var headers = ["Content-Type: application/json"]

	# 7. ¡HACEMOS LA LLAMADA!
	gemini_request.request(api_url, headers, HTTPClient.METHOD_POST, body_json)


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
			# Calculamos posición frente a la cámara
			var cam_transform = camera.global_transform
			sprite.global_transform.origin = cam_transform.origin + cam_transform.basis.z * -2.0
