extends Control

@onready var grid_container: GridContainer = %MineGrid
@onready var menu_button: Button = %MenuButton
@onready var close_button: Button = %CloseButton
@onready var pause_menu: PanelContainer = %PauseMenu
@onready var mines_label: Label = %MinesLabel
@onready var timer_label: Label = %TimerLabel
@onready var victory_panel: PanelContainer = %VictoryPanel
@onready var blocker: ColorRect = %Blocker
@onready var victory_button: Button = %VictoryAgainButton
@onready var victory_time_label: Label = %VictoryTimeLabel
@onready var best_time_container: Container = %BestTimeContainer
@onready var best_time_label: Label = %BestTimeLabel

var first_click_done := false
var tiles := []
var mines := int(Globals.mines)
var is_timer_paused := true
var timer_count := 0
var elapsed := 0.0
var is_game_over := false
var non_mine_tiles: int = Globals.grid_height * Globals.grid_width - Globals.mines
var revealed_tiles := 0
var has_won := false
var difficulty := Globals.last_difficulty

func _ready() -> void:
	menu_button.grab_focus()
	
	grid_container.set_columns(Globals.grid_width)
	create_grid()

func _process(delta: float) -> void:
	if first_click_done and not is_game_over and timer_count < 9999 and not is_timer_paused:
		elapsed += delta
		if elapsed >= 1.0:
			elapsed -= 1.0
			timer_count += 1
			timer_label.text = str(timer_count).pad_zeros(4)

func create_grid() -> void:
	is_game_over = false
	
	blocker.hide()
	
	menu_button.text = tr("GAME_MENU_BUTTON")
	has_won = false
	
	timer_count = 0
	revealed_tiles = 0
	
	# Clear grid
	for n in grid_container.get_children():
		# grid_container.remove_child(n)
		n.queue_free()
	
	tiles.clear()
	
	var tile_count = Globals.grid_height * Globals.grid_width
	
	for i in tile_count:
		var tile = load("res://Scenes/tile_scene.tscn").instantiate()
		tile.index = i
		tile.connect("tile_clicked", _on_tile_clicked)
		grid_container.add_child(tile)
		tiles.append(tile)
	
	for n in grid_container.get_children():
		n.add_to_group("tiles")
	
	mines = Globals.mines
	mines_label.text = str(mines)
	timer_label.text = "0000"
	
	first_click_done = false
	get_tree().call_group("tiles", "set_no_click", false)

func _on_tile_clicked(index: int, is_right_click: bool):
	var tile = tiles[index]
	
	if not tile.no_click:
		if not is_right_click:
			if not first_click_done:
				first_click_done = true
				generate_mines(index)
				calculate_numbers()
			
			if tile.is_revealed:
				check_and_reveal(index)
			elif not tile.is_flag:
				reveal_tile(index)
			
			is_timer_paused = false
		else:
			if first_click_done:
				if not tile.is_flag and not tile.is_revealed and mines > 0:
					mines -= 1
					mines_label.text = str(mines)
					tile.label.text = "🚩"
					tile.is_flag = true
				elif tile.is_flag and not tile.is_revealed:
					mines += 1
					mines_label.text = str(mines)
					tile.label.text = ""
					tile.is_flag = false

func generate_mines(index) -> void:
	var forbidden := get_neighbors(index)
	forbidden.append(index)
	
	var available := []
	var tile_count := int(Globals.grid_height) * int(Globals.grid_width)
	
	for tile in tile_count:
		if tile not in forbidden:
			available.append(tile)
	
	available.shuffle()
	
	var mine_position = available.slice(0, Globals.mines)
	
	for mine in mine_position:
		tiles[mine].is_mine = true
		tiles[mine].add_to_group("mines")
		tiles[mine].label.add_to_group("mines_labels")

func get_neighbors(index) -> Array:
	var neighbors := []
	var x = index % Globals.grid_width
	var y = index / Globals.grid_width
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			var nx = x + dx
			var ny = y + dy
			
			if nx < 0 or ny < 0 or nx >= Globals.grid_width or ny >= Globals.grid_height:
				continue
			
			var neighbor_index = ny * Globals.grid_width + nx
			
			neighbors.append(neighbor_index)
	
	return neighbors

func calculate_numbers() -> void:
	for tile in tiles:
		if tile.is_mine:
			continue
		
		var mine_check : int = 0
		var neighbors := get_neighbors(tile.index)
		
		for neighbor in neighbors:
			if tiles[neighbor].is_mine:
				mine_check += 1
		
		tile.mine_number = mine_check
		
		match mine_check:
			1:
				tile.label.add_theme_color_override("font_color", Color(0.0, 0.0, 1.0))
			2:
				tile.label.add_theme_color_override("font_color", Color(0.0, 0.5, 0.0))
			3:
				tile.label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0))
			4:
				tile.label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.5))
			5:
				tile.label.add_theme_color_override("font_color", Color(0.5, 0.0, 0.0))
			6:
				tile.label.add_theme_color_override("font_color", Color(0.0, 0.5, 0.5))
			7:
				tile.label.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0))
			8:
				tile.label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func check_and_reveal(index) -> void:
	var neighbors = get_neighbors(index)
	var flags := 0
	var is_lose := false
	
	for neighbor in neighbors:
		var tile = tiles[neighbor]
		
		if tile.is_flag:
			flags += 1
			if not tile.is_mine:
				is_lose = true
		elif not tile.is_revealed:
			tile.press_temporarily()
	
	if tiles[index].mine_number == flags:
		if is_lose:
			lose_game()
			return
		
		for neighbor in neighbors:
			if not tiles[neighbor].is_flag and not tiles[neighbor].is_revealed:
				reveal_tile(neighbor)

func reveal_tile(index) -> void:
	var tile = tiles[index]
	
	tile.reveal_as_pressed()
	
	if tile.is_mine:
		lose_game()
		return
	
	if tile.mine_number != 0:
		tile.label.text = str(tile.mine_number)
	
	if tile.mine_number == 0:
		var neighbors = get_neighbors(index)
		for neighbor in neighbors:
			if not tiles[neighbor].is_revealed:
				reveal_tile(neighbor)
	
	revealed_tiles += 1
	if revealed_tiles == non_mine_tiles:
		victory()

func lose_game() -> void:
	is_game_over = true
	is_timer_paused = true
	
	get_tree().call_group("mines_labels", "set_text", "💣")
	get_tree().call_group("mines", "reveal_as_pressed")
	get_tree().call_group("tiles", "set_no_click", true)

func victory() -> void:
	is_game_over = true
	is_timer_paused = true
	
	get_tree().call_group("mines_labels", "set_text", "🚩")
	get_tree().call_group("tiles", "set_no_click", true)
	
	menu_button.text = tr("GAME_VICTORY_LABEL")
	has_won = true

func _on_menu_button_pressed() -> void:
	if not is_timer_paused and first_click_done:
		is_timer_paused = true
	
	if has_won:
		victory_time_label.text = str(int(timer_label.text)) + "s"
		
		if difficulty == 3:
			best_time_container.hide()
		else:
			best_time_container.show()
			
			var current_time = int(timer_label.text)
			var best_time = Globals.best_times[difficulty]
			
			if best_time == 0 or current_time < best_time:
				Globals.best_times[difficulty] = current_time
				Globals.save_game()
			
			best_time_label.text = str(Globals.best_times[difficulty]) + "s"
		
		open_menu(victory_panel, victory_button)
	else:
		open_menu(pause_menu, close_button)

func _on_close_button_pressed() -> void:
	if is_timer_paused and first_click_done:
		is_timer_paused = false
	close_menu(pause_menu)

func _on_restart_button_pressed() -> void:
	close_menu(pause_menu)
	create_grid()

func open_menu(menu: Control, button_to_focus: Button) -> void:
	menu_button.disabled = true
	menu_button.focus_mode = Control.FOCUS_NONE
	get_tree().call_group("tiles", "set_disabled", true)
	get_tree().call_group("tiles", "set_focus_mode", 0)
	
	menu.show()
	button_to_focus.grab_focus()
	
	blocker.show()

func close_menu(menu: Control) -> void:
	menu_button.disabled = false
	menu_button.focus_mode = Control.FOCUS_ALL
	get_tree().call_group("tiles", "set_disabled", false)
	get_tree().call_group("tiles", "set_focus_mode", 2)
	
	menu.hide()
	menu_button.grab_focus()
	
	blocker.hide()

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_victory_again_button_pressed() -> void:
	close_menu(victory_panel)
	create_grid()

func _on_victory_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
