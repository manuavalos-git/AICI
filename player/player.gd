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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim_tree.active = true

func _input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _unhandled_input(event):
	if Input.is_action_just_pressed("toggle_AICI"):
		var current = state_machine.get_current_node()
		if current == "Idle":
			mundo_script.set_chatbot_visibility(true)
			state_machine.travel("ChatbotUP") 
		elif current == "ChatbotUP":
			mundo_script.set_chatbot_visibility(false)
			state_machine.travel("ChatbotDOWN")
	elif Input.is_action_just_pressed("interact"):
		var current_state = state_machine.get_current_node()
		if current_state != "Touch":
			if current_state == "ChatbotUP":
				mundo_script.set_chatbot_visibility(false)
			state_machine.travel("Touch")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
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
	move_and_slide()
