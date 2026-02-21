extends Button

signal tile_clicked(index: int, is_right_click: bool)

@onready var label: Label = $Label

var mine_number : int
var index : int
var is_mine := false
var is_revealed := false
var is_flag := false
var no_click := false

func reveal_as_pressed() -> void:
	is_revealed = true
	var pressed_style = get_theme_stylebox("pressed", "Button")
	add_theme_stylebox_override("normal", pressed_style)
	add_theme_stylebox_override("hover", pressed_style)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("tile_clicked", index, false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			emit_signal("tile_clicked", index, true)

func set_no_click(boo) -> void:
	if boo:
		no_click = true
	elif not boo:
		no_click = false

func press_temporarily() -> void:
	if not is_revealed and not is_flag:
		var original_normal = get_theme_stylebox("normal", "Button")
		var original_hover = get_theme_stylebox("hover", "Button")
		
		var pressed_style = get_theme_stylebox("pressed", "Button")
		add_theme_stylebox_override("normal", pressed_style)
		add_theme_stylebox_override("hover", pressed_style)
		
		var timer = get_tree().create_timer(0.1)
		await timer.timeout
		
		if not is_revealed:
			add_theme_stylebox_override("normal", original_normal)
			add_theme_stylebox_override("hover", original_hover)
