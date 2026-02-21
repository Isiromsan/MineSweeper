extends Control

@onready var option_button: OptionButton = %DifficultyOptions
@onready var exit_panel: PanelContainer = %ExitPanelContainer
@onready var back_button: Button = %BackButton
@onready var back_back_button: Button = %BackBackButton
@onready var width_value_label: SpinBox = %WidthValueLabel
@onready var height_value_label: SpinBox = %HeightValueLabel
@onready var mines_value_label: SpinBox = %MinesValueLabel
@onready var width_slider: HSlider = %WidthSlider
@onready var height_slider: HSlider = %HeightSlider
@onready var mines_slider: HSlider = %MinesSlider
@onready var best_time_label: Label = %BestTimeLabel
@onready var times_container: Container = %TimeMarginContainer
@onready var confirmation_panel: Container = $ConfirmationPanelContainer
@onready var yes_button: Button = %YesButton
@onready var reset_button: Button = %ResetTimes
@onready var language_options: OptionButton = %LanguageOptions

var main_menu: Control

func _ready():
	back_button.grab_focus()
	width_value_label.value = Globals.grid_width
	height_value_label.value = Globals.grid_height
	mines_value_label.value = Globals.mines
	
	get_tree().call_group("mines_buttons", "set_max", width_value_label.value * height_value_label.value - 9)
	
	option_button.select(Globals.last_difficulty)
	language_options.select(Globals.current_language)
	
	if (option_button.get_selected_id() != 3):
		get_tree().call_group("custom_diff_buttons", "set_editable", false)
		get_tree().call_group("focus_buttons", "set_focus_mode", 0)
	
	call_deferred("_update_best_times", option_button.selected)

func _update_best_times(difficulty: int) -> void:
	if difficulty == 3:
		times_container.hide()
	else:
		times_container.show()
		best_time_label.text = str(Globals.best_times[difficulty])

func _exit_tree() -> void:
	Globals.save_game()

func _on_apply_button_pressed() -> void:
	Globals.grid_width = int(width_value_label.value)
	Globals.grid_height = int(height_value_label.value)
	Globals.mines = int(mines_value_label.value)
	Globals.last_difficulty = option_button.get_selected_id()
	
	if main_menu:
		main_menu.get_node("VBoxContainer/StartButton").grab_focus()
	queue_free()

func _on_back_button_pressed() -> void:
	get_tree().call_group("buttons_disable", "set_disabled", true)
	get_tree().call_group("buttons_disable", "set_focus_mode", 0)
	
	exit_panel.visible = true
	back_back_button.grab_focus()

func _on_back_back_button_pressed() -> void:
	get_tree().call_group("buttons_disable", "set_disabled", false)
	get_tree().call_group("buttons_disable", "set_focus_mode", 2)
	
	exit_panel.visible = false
	back_button.grab_focus()

func _on_back_exit_button_pressed() -> void:
	if main_menu:
		main_menu.get_node("VBoxContainer/StartButton").grab_focus()
	queue_free()

func _on_option_button_item_selected(index: int) -> void:
	_update_best_times(index)
	
	if index == 3:
		get_tree().call_group("custom_diff_buttons", "set_editable", true)
		get_tree().call_group("focus_buttons", "set_focus_mode", 2)
	else:
		get_tree().call_group("custom_diff_buttons", "set_editable", false)
		get_tree().call_group("focus_buttons", "set_focus_mode", 0)
		
		match index:
			0:
				width_value_label.value = 8
				height_value_label.value = 8
				mines_value_label.value = 10
				get_tree().call_group("mines_buttons", "set_max", width_value_label.value * height_value_label.value - 9)
			1:
				width_value_label.value = 16
				height_value_label.value = 16
				mines_value_label.value = 40
				get_tree().call_group("mines_buttons", "set_max", width_value_label.value * height_value_label.value - 9)
			2:
				width_value_label.value = 30
				height_value_label.value = 16
				mines_value_label.value = 99
				get_tree().call_group("mines_buttons", "set_max", width_value_label.value * height_value_label.value - 9)

func _on_width_slider_value_changed(value: int) -> void:
	width_value_label.value = value

func _on_height_slider_value_changed(value: int) -> void:
	height_value_label.value = value

func _on_mines_slider_value_changed(value: int) -> void:
	mines_value_label.value = value

func _on_width_value_label_value_changed(value: int) -> void:
	width_slider.value = value
	get_tree().call_group("mines_buttons", "set_max", value * height_value_label.value - 9)

func _on_height_value_label_value_changed(value: int) -> void:
	height_slider.value = value
	get_tree().call_group("mines_buttons", "set_max", width_value_label.value * value - 9)

func _on_mines_value_label_value_changed(value: int) -> void:
	mines_slider.value = value

func _on_reset_times_pressed() -> void:
	confirmation_panel.show()
	yes_button.grab_focus()

func _on_yes_button_pressed() -> void:
	var difficulty = option_button.selected
	
	Globals.best_times[difficulty] = 0
	_update_best_times(difficulty)
	Globals.save_game()
	
	_on_no_button_pressed()

func _on_no_button_pressed() -> void:
	confirmation_panel.hide()
	reset_button.grab_focus()

func _on_language_options_item_selected(index: int) -> void:
	Globals.current_language = index
	TranslationServer.set_locale(Globals.languages[index])
