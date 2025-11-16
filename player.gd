extends CharacterBody3D

# Velocidades
var speed = 10.0
var sprint_speed = 20.0
var sensitivity = 0.0018

# Para capturar el mouse
var mouse_captured = true

# Control de movimiento habilitado/deshabilitado
var movement_enabled = true

var yaw := 0.0
var pitch := 0.0

# Referencias
@onready var camera = $Head/Camera3D
@onready var status_label = get_node_or_null("../StatusLabel3D")

# Gravedad
var gravity = -20.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_status_label()

func update_status_label():
	if status_label:
		if movement_enabled:
			status_label.text = "🎮 FREE CAM: ACTIVADA\nWASD: Mover | Mouse: Mirar | Espacio: Subir | Shift: Bajar\nCTRL: Desactivar camara | T: Minimizar/Maximizar chat\n💬 CHAT: Click + Arrastra en 3D | Rueda: Zoom | Click en texto para escribir  | C para activar el chat"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "🎮 FREE CAM: DESACTIVADA\nCTRL para activar | T: Minimizar/Maximizar chat\n💬 CHAT: Click + Arrastra en 3D | Rueda: Zoom | Click en texto para escribir | C para activar el chat"
			status_label.modulate = Color.RED

func _input(event):
	# Alternar movimiento con CTRL
	if Input.is_key_pressed(KEY_CTRL) and event is InputEventKey and event.pressed:
		movement_enabled = !movement_enabled
		update_status_label()
		if movement_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_captured = false

	# Alternar captura del mouse con ESC
	if event.is_action_pressed("ui_cancel"):
		mouse_captured = !mouse_captured
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


	# Rotación
	if event is InputEventMouseMotion and mouse_captured and movement_enabled:
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity

		# limitar pitch
		pitch = clamp(pitch, deg_to_rad(-85), deg_to_rad(85))

		# aplicar rotaciones suaves y estables
		rotation.y = yaw
		camera.rotation.x = pitch


func _physics_process(delta):
	if not movement_enabled or not mouse_captured:
		return

	# Agregar gravedad si querés que caiga
	velocity.y += gravity * delta

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

	var direction = Vector3.ZERO

	if input_dir.z != 0:
		direction += transform.basis.z * input_dir.z
	if input_dir.x != 0:
		direction += transform.basis.x * input_dir.x
	if input_dir.y != 0:
		direction.y = input_dir.y

	velocity = direction.normalized() * speed


	move_and_slide()
