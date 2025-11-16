extends Control

var is_minimized = false
var original_size = Vector2.ZERO

@onready var vbox = $VBoxContainer
@onready var color_rect = $ColorRect
@onready var rich_text = $VBoxContainer/RichTextLabel
@onready var line_edit = $VBoxContainer/LineEdit
@onready var title_label = $TitleLabel

func _ready():
	original_size = size
	# Hacer el ColorRect como área de arrastre
	color_rect.mouse_filter = Control.MOUSE_FILTER_PASS

func _process(_delta):
	# Actualizar el cursor según la posición del mouse
	if not is_minimized:
		var mouse_pos = get_global_mouse_position()
		var line_edit_rect = line_edit.get_global_rect()
		if line_edit_rect.has_point(mouse_pos):
			mouse_default_cursor_shape = Control.CURSOR_IBEAM
		elif get_global_rect().has_point(mouse_pos):
			mouse_default_cursor_shape = Control.CURSOR_MOVE
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		# Si está minimizado, siempre mostrar cursor de mover
		if get_global_rect().has_point(get_global_mouse_position()):
			mouse_default_cursor_shape = Control.CURSOR_MOVE
		else:
			mouse_default_cursor_shape = Control.CURSOR_ARROW

func toggle_minimize():
	is_minimized = !is_minimized
	if is_minimized:
		# Minimizar - solo mostrar una barra pequeña con el título
		rich_text.visible = false
		line_edit.visible = false
		vbox.visible = false
		custom_minimum_size = Vector2(400, 45)
		size = Vector2(400, 45)
		title_label.text = "💬 CHAT AI (Minimizado - T para abrir | C para escribir)"
	else:
		# Maximizar - mostrar todo
		rich_text.visible = true
		line_edit.visible = true
		vbox.visible = true
		custom_minimum_size = Vector2.ZERO
		size = original_size
		title_label.text = "💬 CHAT AI (C escribir | T minimizar | ESC salir)"
