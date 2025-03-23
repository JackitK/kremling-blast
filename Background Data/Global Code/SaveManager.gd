extends Node

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save"
const LEVELS_SAVE_PATH : String = "user://LevelData.save"

var settings_data_dict: Dictionary = {}
var level_progress_dict: Dictionary = {}

var save_data:SaveData

func _ready():
	SettingsSignalBus.set_settings_dictionary.connect(on_settings_save)
	SettingsSignalBus.set_levels_dictionary.connect(on_levels_save)
	save_data = SaveData.load_or_create()
	load_settings_data()
	load_levels_data()
	
func on_settings_save(data : Dictionary) -> void:
	var save_settings_data_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.WRITE)
	
	var json_data_string = JSON.stringify(data)
	
	save_settings_data_file.store_line(json_data_string)

func load_settings_data() -> void:
	print("loading settings data")
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return
		
	var save_settings_data_file = FileAccess.open(SETTINGS_SAVE_PATH, FileAccess.READ)
	var loaded_data : Dictionary = {}
	
	while save_settings_data_file.get_position() < save_settings_data_file.get_length():
		var json_string = save_settings_data_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
		
	SettingsSignalBus.emit_load_settings_data(loaded_data)

func on_levels_save(data: Dictionary) -> void:
	var data_file = FileAccess.open_encrypted_with_pass(LEVELS_SAVE_PATH, FileAccess.WRITE, "SaraRules")
	
	var json_data_string = JSON.stringify(data)
	
	data_file.store_line(json_data_string)

func load_levels_data() -> void:
	print("loading settings data")
	if not FileAccess.file_exists(LEVELS_SAVE_PATH):
		return
		
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(LEVELS_SAVE_PATH, FileAccess.READ, "SaraRules")
	var loaded_data : Dictionary = {}
	
	while save_settings_data_file.get_position() < save_settings_data_file.get_length():
		var json_string = save_settings_data_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
		
	SettingsSignalBus.emit_load_levels_data(loaded_data)
