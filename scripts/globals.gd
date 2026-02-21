extends Node

var saves_folder: String
var saves_dir: String
var grid_width: int = 16
var grid_height: int = 16
var mines: int = 40
var last_difficulty: int = 1
var best_times := [0, 0, 0]
var current_language := 0

var languages = [
	"en", # 0
	"es"  # 1
]

func _ready() -> void:
	_setup_paths()
	load_game()
	TranslationServer.set_locale(languages[current_language])

func _setup_paths() -> void:
	if OS.has_feature("editor"): # Editor
		saves_folder = "user://Savegame"
	else: # Exported
		saves_folder = OS.get_executable_path().get_base_dir().path_join("Savegame")
	
	saves_dir = saves_folder.path_join("savegame.json")

func save_game():
	if not DirAccess.dir_exists_absolute(saves_folder):
		var err = DirAccess.make_dir_recursive_absolute(saves_folder)
		if err != OK:
			push_error("Failed to create folder: " + saves_folder)
			return
	
	var file = FileAccess.open(saves_dir, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file: " + saves_dir)
	
	var data := {
		"grid_width": grid_width,
		"grid_height": grid_height,
		"mines": mines,
		"last_difficulty": last_difficulty,
		"best_times": best_times,
		"current_language": current_language
	}
	
	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if FileAccess.file_exists(saves_dir):
		var file = FileAccess.open(saves_dir, FileAccess.READ)
		if file == null:
			push_error("Failed to open file: " + saves_dir)
			return
		
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data:
			grid_width = int(data.get("grid_width", 16))
			grid_height = int(data.get("grid_height", 16))
			mines = int(data.get("mines", 40))
			last_difficulty = int(data.get("last_difficulty", 1))
			current_language = data.get("current_language", 0)
			best_times = data.get("best_times", [0, 0, 0])
			
			for i in best_times.size():
				best_times[i] = int(best_times[i])
