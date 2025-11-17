extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var counter_label = $Label3D

# --- Definir los Estados Posibles de la Máquina ---
enum MachineState {
	OFF,			# La máquina no tiene energía
	STANDBY,		# Tiene energía, pero está en reposo (esperando)
	RUNNING_SINGLE,	# Haciendo UN ciclo
	RUNNING_AUTO,	# Haciendo ciclos sin parar
	MANUAL_TEST,	# En modo "Tests", botones manuales activos
	EMERGENCY_STOP,	# Todo clavado por la emergencia
	POST_EMERGENCY	# Esperando el 'Initial State' después de la emergencia
}

# --- LA MEMORIA MAESTRA (El Cerebro) ---
#	Empezamos en STANDBY porque 'Energize' está roto.
var current_state = MachineState.STANDBY
var display_text = "----"
# --- Tus "Memorias Pequeñas" (Perillas) ---
# (Esto está perfecto como lo tenías)
var disorder_knob_is_in_disorder_position = true
var normal_knob_is_in_normal_position = true
var licence_knob_is_in_one_position = true
var cycle_knob_is_in_single_position = true
#var energize_knob_is_off = true
const MAX_DISPLAY_CHARS = 8 # (Ajustá este número a tu gusto)


# --- Función _ready() ---
# Se ejecuta UNA VEZ al empezar.
# Pone las luces en el estado correcto para STANDBY.
func _ready():
	# ¡ARREGLADO! Solo llamamos a UN estado.
	animation_player.play("state_standby")
	update_counter_display()
	
func update_counter_display():
	counter_label.text = display_text.left(MAX_DISPLAY_CHARS)

# --- BOTONES MANUALES ---
# (Solo funcionan si el estado es MANUAL_TEST)

func _on_press_more_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("press_more")
				display_text = "PRESS +"
				update_counter_display()
			
func _on_press_less_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("press_less")
				display_text = "PRESS -"
				update_counter_display()

func _on_matrix_more_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("matrix_more")
				display_text = "MATRIX +"
				update_counter_display()
			
func _on_matrix_less_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("matrix_less")
				display_text = "MATRIX -"
				update_counter_display()

func _on_plate_more_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("plate_more")
				display_text = "PLATE +"
				update_counter_display()
			
func _on_plate_less_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("plate_less")
				display_text = "PLATE -"
				update_counter_display()

func _on_pyd_more_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("pyd_more")
				display_text = "P&D +"
				update_counter_display()
			
func _on_pyd_less_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("pyd_less")
				display_text = "P&D -"
				update_counter_display()

func _on_lifter_more_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("lifter_more")
				display_text = "LIFTER +"
				update_counter_display()

func _on_lifter_less_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.MANUAL_TEST:
				animation_player.play("lifter_less")
				display_text = "LIFTER -"
				update_counter_display()

# --- BOTONES DE CONTROL Y RESET ---

func _on_counter_reset_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.STANDBY or current_state == MachineState.MANUAL_TEST:
				animation_player.play("counter_reset")
				display_text = "----"
				update_counter_display()

func _on_initial_state_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if current_state == MachineState.POST_EMERGENCY:
				animation_player.play("initial_state")
				animation_player.play("state_standby")
				current_state = MachineState.STANDBY
				display_text = "INITIAL"
				update_counter_display()
			elif current_state == MachineState.STANDBY:
				animation_player.play("initial_state")
				display_text = "INITIAL"
				update_counter_display()

# --- BOTONES PRINCIPALES (START/STOP/EMERGENCY) ---

func _on_start_button_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.STANDBY:
				animation_player.play("start")
				animation_player.play("state_running")
				
				if cycle_knob_is_in_single_position == true:
					current_state = MachineState.RUNNING_SINGLE
					display_text = "RUN-SNGL"
				else:
					current_state = MachineState.RUNNING_AUTO
					display_text = "RUN-AUTO"
				update_counter_display()
			
func _on_stop_button_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			# --- CEREBRO ---
			if current_state == MachineState.RUNNING_SINGLE or current_state == MachineState.RUNNING_AUTO:
				animation_player.play("stop")
				animation_player.play("state_standby")
				current_state = MachineState.STANDBY
				display_text = "STOP"
				update_counter_display()

func _on_emergency_stop_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if current_state != MachineState.EMERGENCY_STOP:
				animation_player.play("state_emergency")
				current_state = MachineState.EMERGENCY_STOP
				display_text = "ALERT"
				update_counter_display()
			else:
				animation_player.play_backwards("emergency")
				current_state = MachineState.POST_EMERGENCY
				display_text = "NEED STATE" # (Reset Requerido)
				update_counter_display()

# --- PERILLAS (INPUTS QUE TAMBIÉN CAMBIAN ESTADO) ---

func _on_disorder_order_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and not animation_player.is_playing():
			if current_state == MachineState.STANDBY:
				if disorder_knob_is_in_disorder_position == true:
					animation_player.play("disorder_to_order")
					disorder_knob_is_in_disorder_position = false
					display_text = "ORDER"
				else:
					animation_player.play("order_to_disorder")
					disorder_knob_is_in_disorder_position = true
					display_text = "DISORDER"
				update_counter_display()

func _on_normal_tests_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and not animation_player.is_playing():
			if current_state == MachineState.STANDBY or current_state == MachineState.MANUAL_TEST:
				if normal_knob_is_in_normal_position == true:
					animation_player.play("normal_to_tests")
					normal_knob_is_in_normal_position = false
					current_state = MachineState.MANUAL_TEST
					display_text = "TESTS"
				else:
					animation_player.play("tests_to_normal")
					normal_knob_is_in_normal_position = true
					current_state = MachineState.STANDBY
					display_text = "NORMAL"
				update_counter_display()

func _on_license_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and not animation_player.is_playing():
			if current_state == MachineState.STANDBY:
				if licence_knob_is_in_one_position == true:
					animation_player.play("one_to_two")
					licence_knob_is_in_one_position = false
					display_text = "TWO LIC"
				else:
					animation_player.play("two_to_one")
					licence_knob_is_in_one_position = true
					display_text = "ONE LIC"
				update_counter_display()

func _on_cycle_detector_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed() and not animation_player.is_playing():
			if current_state == MachineState.STANDBY:
				if cycle_knob_is_in_single_position == true:
					animation_player.play("single_to_auto")
					cycle_knob_is_in_single_position = false
					display_text = "AUTO"
				else:
					animation_player.play("auto_to_single")
					cycle_knob_is_in_single_position = true
					display_text = "SINGLE"
				update_counter_display()
