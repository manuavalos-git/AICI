extends Camera3D

# Velocidades
var speed = 10.0
var sprint_speed = 20.0
var sensitivity = 0.2

# Para capturar el mouse
var mouse_captured = false

# Control de movimiento habilitado/deshabilitado
var movement_enabled = true

# Referencia al label 3D
@onready var status_label = get_node_or_null("../StatusLabel3D")

func _ready():
	# Capturar el mouse al iniciar
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
	update_status_label()

func update_status_label():
	if status_label:
		if movement_enabled:
			status_label.text = "🎮 FREE CAM: ACTIVADA\nWASD: Mover | Mouse: Mirar | Espacio: Subir | Shift: Bajar\nCTRL: Desactivar camara | T: Minimizar/Maximizar chat\n💬 CHAT: Click + Arrastra en 3D | Rueda: Zoom | Click en texto para escribir"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "🎮 FREE CAM: DESACTIVADA\nCTRL para activar | T: Minimizar/Maximizar chat\n💬 CHAT: Click + Arrastra en 3D | Rueda: Zoom | Click en texto para escribir"
			status_label.modulate = Color.RED

func _input(event):
	# Alternar movimiento con CTRL
	if Input.is_key_pressed(KEY_CTRL) and event is InputEventKey and event.pressed and event.keycode == KEY_CTRL:
		movement_enabled = !movement_enabled
		update_status_label()
		# Si desactivamos el movimiento, liberar el mouse automáticamente
		if not movement_enabled:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_captured = false
	
	# Alternar captura del mouse con ESC
	if event.is_action_pressed("ui_cancel"):
		if mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouse_captured = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true
	
	# Rotación con movimiento del mouse (solo si el movimiento está habilitado)
	if event is InputEventMouseMotion and mouse_captured and movement_enabled:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-event.relative.y * sensitivity))
		
		# Limitar rotación vertical
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
	# No mover si los controles están deshabilitados
	if not mouse_captured or not movement_enabled:
		return
	
	# Velocidad actual (sin usar Shift para velocidad, ahora Shift baja)
	var current_speed = speed
	
	# Dirección de movimiento
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	
	# Subir con Espacio
	if Input.is_key_pressed(KEY_SPACE):
		input_dir.y += 1
	
	# Bajar con Shift
	if Input.is_key_pressed(KEY_SHIFT):
		input_dir.y -= 1
	
	# Aplicar movimiento
	var direction = (transform.basis * input_dir).normalized()
	position += direction * current_speed * delta

# Función para desactivar movimiento desde otros scripts
func disable_movement():
	if movement_enabled:
		movement_enabled = false
		update_status_label()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false

# Función para activar movimiento desde otros scripts
func enable_movement():
	if not movement_enabled:
		movement_enabled = true
		update_status_label()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_captured = true

