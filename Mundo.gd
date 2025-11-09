extends Node3D

@export var line_edit: LineEdit
@export var rich_text_label: RichTextLabel
@export var gemini_request: HTTPRequest
@onready var sprite = $Player/Camera3D/Sprite3D
@onready var camera = $Player/Camera3D
@onready var sub_viewport_node = $Player/Camera3D/SubViewport
@onready var show_timer = $ShowTimer
@onready var hide_timer = $HideTimer
var isVisible = false
var api_key = "AIzaSyDwgIreZnegfT7JnY6b91_lHVIOK4RW0WI"
var api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=" + api_key

func _ready():
	line_edit.text_submitted.connect(_on_text_submitted)
	gemini_request.request_completed.connect(_on_request_completed)
	show_timer.timeout.connect(_on_show_timer_timeout)
	hide_timer.timeout.connect(_on_hide_timer_timeout)
	sprite.position = Vector3(0.25, 0.15, -0.3) 
	sprite.visible = false
	isVisible = false
	line_edit.editable = false
	line_edit.focus_mode = Control.FOCUS_NONE

func set_chatbot_visibility(visible: bool):
	if visible:
		hide_timer.stop() 
		show_timer.start()
	else:
		show_timer.stop()
		hide_timer.start()
		line_edit.release_focus()
		line_edit.editable = false
		line_edit.focus_mode = Control.FOCUS_NONE

func _on_show_timer_timeout():
	sprite.visible = true
	isVisible = true
	line_edit.editable = true
	line_edit.focus_mode = Control.FOCUS_ALL
	#line_edit.grab_focus()
	
func _on_hide_timer_timeout():
	sprite.visible = false
	isVisible = false

func _on_text_submitted(text):
	rich_text_label.text += "\n[color=lightblue]Tú:[/color] " + text
	line_edit.text = ""
	rich_text_label.text += "\n[color=orange]Bot:[/color] Pensando..."
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
	var body_json = JSON.stringify(body)
	var headers = ["Content-Type: application/json"]
	gemini_request.request(api_url, headers, HTTPClient.METHOD_POST, body_json)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		rich_text_label.text += "\n[color=red]Error:[/color] No se pudo conectar. Código: " + str(response_code)
		print("Error de API: ", body.get_string_from_utf8())
		return
	var response_text = body.get_string_from_utf8()
	var json_data = JSON.parse_string(response_text)
	if json_data.get("candidates") and json_data.candidates[0].get("content"):
		var bot_response = json_data.candidates[0].content.parts[0].text
		rich_text_label.text += "\n[color=orange]Bot:[/color] " + bot_response
	else:
		rich_text_label.text += "\n[color=red]Error:[/color] La API devolvió una respuesta vacía."
		print("Respuesta vacía o bloqueada: ", response_text)

func _input(event):
	if event.is_action_pressed("ui_focus_next"): 
		if line_edit.has_focus():
			line_edit.release_focus()
		else:
			line_edit.grab_focus()
		get_viewport().set_input_as_handled()
	elif line_edit.has_focus():
		sub_viewport_node.push_input(event)
		get_viewport().set_input_as_handled()
