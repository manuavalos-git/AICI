extends CharacterBody3D

@export var MOUSE_SENSITIVITY = 0.002
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera = $Camera3D
@onready var arm_rig = $Camera3D/"Low Poly Arm Rig"
@onready var anim_player = $Camera3D/"Low Poly Arm Rig"/AnimationPlayer
@onready var anim_tree = $Camera3D/"Low Poly Arm Rig"/AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var mundo_script = get_node("/root/Mundo")
@onready var raycast = $Camera3D/RayCast3D # ¡Bien! Ya lo tenías
var current_panel_camera = null
var is_interacting = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim_tree.active = true

func _input(event):
	if is_interacting:
		return
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _unhandled_input(event):
	# Tu lógica de AICI (¡ESTÁ PERFECTA, NO SE TOCA!)
	if Input.is_action_just_pressed("toggle_AICI"):
		var current = state_machine.get_current_node()
		if current == "Idle":
			mundo_script.set_chatbot_visibility(true)
			state_machine.travel("ChatbotUP")
		elif current == "ChatbotUP":
			mundo_script.set_chatbot_visibility(false)
			state_machine.travel("ChatbotDOWN")
	
	# Tu lógica de "interact" (¡AHORA CONTROLA TODO!)
	elif Input.is_action_just_pressed("interact"):
		if is_interacting:
			# Si ya estábamos interactuando, apretar 'E' nos saca
			stop_interacting()
		else:
			# Si estábamos en modo FPS, apretar 'E' nos mete
			# ¡PERO SOLO SI ESTAMOS MIRANDO UN PANEL!
			start_interacting() # La lógica ahora está DENTRO de la función

func _physics_process(delta):
	# La gravedad se aplica siempre
	if not is_on_floor():
		velocity.y -= gravity * delta

	# El movimiento y salto solo se procesan si NO estamos interactuando
	if not is_interacting:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		# Si estamos interactuando, frenamos al jugador
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

# (Tu script...)

# Esta función ahora chequea el RayCast y cambia la cámara
func start_interacting():
	# 1. ¿Estamos apuntando a algo?
	if not raycast.is_colliding():
		return # No pegó a nada, no interactuar
		
	# 2. ¿Lo que tocamos tiene una "panel_camera"?
	var collider = raycast.get_collider()
	
	# --- ¡PLAN B! Si esto falla, la consola nos dirá qué tocamos ---
	print("DEBUG: El RayCast pegó contra: ", collider.name)
	
	# ¡ARREGLO ACÁ!
	# ¡No usamos .get_parent()! ¡El collider ES el panel!
	if not collider.has_node("panel_camera"):
		print("DEBUG: ¡'"+ collider.name + "' no tiene un hijo 'panel_camera'!")
		return # Pegó, pero no es un panel

	# --- ¡OK, ES UN PANEL! Empezamos la interacción ---
	
	is_interacting = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# ¡ARREGLO ACÁ TAMBIÉN!
	# ¡No usamos .get_parent()!
	current_panel_camera = collider.get_node("panel_camera")
	
	# 5. ¡Hacemos el CAMBIO DE CÁMARAS!
	camera.set_current(false) # Apagamos la del jugador
	current_panel_camera.set_current(true) # Encendemos la del panel
	
	# 6. Mantenemos tu animación de "Touch"
	var current_state = state_machine.get_current_node()
	if current_state != "Touch":
		if current_state == "ChatbotUP":
			mundo_script.set_chatbot_visibility(false)
		state_machine.travel("Touch")

func stop_interacting():
	is_interacting = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# ¡Revertimos las cámaras!
	if current_panel_camera != null:
		current_panel_camera.set_current(false) # Apagamos la del panel
	
	camera.set_current(true) # Encendemos la del jugador
	current_panel_camera = null
	
	# Volvemos a la animación "Idle"
	state_machine.travel("Idle")
