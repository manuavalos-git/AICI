extends CharacterBody3D

@export var MOUSE_SENSITIVITY = 0.0018
@export var SPEED = 10.0
var mouse_captured = true
var movement_enabled = true
var yaw := 0.0
var pitch := 0.0
@onready var camera = $Head/Camera3D
@onready var status_label = get_node_or_null("../StatusLabel3D")
@onready var raycast = $Head/Camera3D/RayCast3D
var current_panel_camera = null
var is_interacting = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_status_label()

func update_status_label():
	if status_label:
		if movement_enabled:
			# CHAT: Click + Arrastra en 3D?
			# T: Minimizar/Maximizar chat?
			status_label.text = "🎮 FREE CAM: ACTIVADA\nWASD: Mover | MOUSE: Mirar | ESPACIO: Subir | SHIFT: Bajar | CTRL: Desactivar camara\n💬 RUEDA: Zoom | TAB para activar el chat y escribir"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "🎮 FREE CAM: DESACTIVADA | CTRL para activar\n💬 RUEDA: Zoom | TAB para activar el chat y escribir"
			status_label.modulate = Color.RED

# SOLO MOUSE
func _input(event):
	if is_interacting:
		return
	if event is InputEventMouseMotion and mouse_captured and movement_enabled:
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch -= event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, deg_to_rad(-85), deg_to_rad(85))
		rotation.y = yaw
		camera.rotation.x = pitch

# SOLO TECLAS/ACCIONES
func _unhandled_input(event):
	if is_interacting:
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_cancel"):
			stop_interacting()
		return 
	if Input.is_action_just_pressed("toggle_movement"):
		movement_enabled = !movement_enabled
		update_status_label()
		if movement_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_captured = false
	if Input.is_action_just_pressed("ui_cancel"):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("interact"):
		start_interacting()


# MOVIMIENTO DE VUELO
func _physics_process(delta):
	if is_interacting:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	if not movement_enabled or not mouse_captured:
		velocity = Vector3.ZERO # Frenar
		move_and_slide()
		return
	var input_dir = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_key_pressed(KEY_SPACE):
		input_dir.y += 1
	if Input.is_key_pressed(KEY_SHIFT):
		input_dir.y -= 1
	var direction = (transform.basis * input_dir).normalized()
	velocity = direction * SPEED
	move_and_slide()

func start_interacting():
	if not raycast.is_colliding():
		return
	var collider = raycast.get_collider()
	if not collider.has_node("panel_camera"):
		print("DEBUG: '"+ collider.name + "' no tiene 'panel_camera'")
		return 
	is_interacting = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	current_panel_camera = collider.get_node("panel_camera")
	camera.set_current(false) 
	current_panel_camera.set_current(true)

func stop_interacting():
	is_interacting = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if current_panel_camera != null:
		current_panel_camera.set_current(false)
	camera.set_current(true) 
	current_panel_camera = null
