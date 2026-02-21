extends Control

@onready var start_button: Button = %StartButton
@onready var back_button: Button = %BackButton
@onready var exit_panel: PanelContainer = %ExitPanelContainer

func _ready():
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_options_button_pressed() -> void:
	var options = load("res://Scenes/options_menu.tscn").instantiate()
	#options.main_menu = self
	get_tree().root.add_child(options)


func _on_quit_button_pressed() -> void:
	get_tree().call_group("hide_buttons", "set_disabled", true)
	get_tree().call_group("hide_buttons", "set_focus_mode", 0)
	exit_panel.visible = true
	back_button.grab_focus()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	get_tree().call_group("hide_buttons", "set_disabled", false)
	get_tree().call_group("hide_buttons", "set_focus_mode", 2)
	exit_panel.visible = false
	start_button.grab_focus()
