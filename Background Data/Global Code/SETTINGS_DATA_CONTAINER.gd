extends Node

@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://Background Data/Resources/Settings/Default_Settings.tres")
@onready var keybind_resource : PlayerKeybindResource = preload("res://Background Data/Resources/Settings/PlayerKeybindDefault.tres")

var subtitles_state : bool = false
var autofire_state : bool = false
var time_trial_state : bool = false
var dash_cancel_state : bool = true
var dash_stomp_state : bool = false
var free_checkpoint_state : bool = false

var window_mode_index : int = 0
var resolution_index : int = 0

var master_volume: float = 0.0
var music_volume: float = 0.0
var sfx_volume: float = 0.0

var loaded_data : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_signals()
	create_storage_dictionary()

func create_storage_dictionary() -> Dictionary:
	var settings_container_dict : Dictionary = {
		"window_mode_index" : window_mode_index,
		"resolution_index" : resolution_index,
		"master_volume_index" : master_volume,
		"music_volume_index" : music_volume,
		"sfx_volume_index" : sfx_volume,
		"subtitles_set" : subtitles_state,
		"autofire_set" : autofire_state,
		#"keybinds" : create_keybind_dictionary()()
	}
	return settings_container_dict

func create_keybind_dictionary() -> Dictionary:
	var keybinds_container_dict = {
		keybind_resource.SHOOT : keybind_resource.shoot,
		keybind_resource.POWER_UP : keybind_resource.power_up,
		keybind_resource.MOVE_LEFT : keybind_resource.move_left_key,
		keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key,
		keybind_resource.MOVE_UP : keybind_resource.move_up_key,
		keybind_resource.MOVE_DOWN : keybind_resource.move_down_key,
		keybind_resource.SHOOT_KEY : keybind_resource.shoot_key,
		keybind_resource.POWER_UP_KEY : keybind_resource.power_up_key,
		
	}
	
	return keybinds_container_dict
	
func create_highscore_dictionary() -> Dictionary:
	var highscore_dict = {
		"score 1" = 0,
		"score 2" = 0,
		"score 3" = 0,
		"score 4" = 0,
		"score 5" = 0
	}
	return highscore_dict

#Accessiblity/Advance options functions
func on_subtitles_toggled(value: bool) -> void:
	subtitles_state = value

func get_subtitle_state() -> bool:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_SUBTITLES_SET
	return subtitles_state

func on_autofire_toggled(value: bool) -> void:
	autofire_state = value

func get_autofire_state() -> bool:
	if loaded_data == {}:
		print("unable to load, getting default state")
		return DEFAULT_SETTINGS.DEFAULT_AUTOFIRE_SET
	print("returning autofire state")
	return autofire_state
	
	
# Window options functions
func on_window_mode_selected(index : int) -> void:
	window_mode_index = index

func get_window_mode_index() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_WINDOW_MODE_INDEX
	return window_mode_index

func on_resolution_selected(index : int) -> void:
	resolution_index = index
	
func get_resoution() -> int:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_RESOLUTION_INDEX
	return resolution_index

# Audio options functions (setting and receiving)
func on_master_sound_set(index : float) -> void:
	master_volume = index
	
func get_master_sound() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MASTER_VOLUME_INDEX
	return master_volume
	
func on_music_sound_set(index : float) -> void:
	music_volume = index
	
func get_music_sound() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MUSIC_VOLUME_INDEX
	return music_volume
	
func on_sfx_sound_set(index : float) -> void:
	sfx_volume = index
	
func get_sfx_sound() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_SFX_VOLUME_INDEX
	return sfx_volume

func set_keybind(action : String, event) -> void:
	match action:
		keybind_resource.SHOOT:
			keybind_resource.shoot = event
		keybind_resource.POWER_UP:
			keybind_resource.power_up = event
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.MOVE_UP:
			keybind_resource.move_up_key = event
		keybind_resource.MOVE_DOWN:
			keybind_resource.move_down_key = event
		keybind_resource.SHOOT_KEY:
			keybind_resource.shoot_key = event
		keybind_resource.POWER_UP_KEY:
			keybind_resource.power_up_key = event

func get_keybind(action : String):
	# If no custom keybinds are saved, then load defaults
	if !loaded_data.has("keybinds"): 
		match action:
			keybind_resource.SHOOT:
				return keybind_resource.DEFAULT_SHOOT
			keybind_resource.POWER_UP:
				return keybind_resource.DEFAULT_POWER_UP
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.MOVE_UP:
				return keybind_resource.DEFAULT_MOVE_UP_KEY
			keybind_resource.MOVE_DOWN:
				return keybind_resource.DEFAULT_MOVE_DOWN_KEY
			keybind_resource.SHOOT_KEY:
				return keybind_resource.DEFAULT_SHOOT_KEY
			keybind_resource.POWER_UP_KEY:
				return keybind_resource.DEFAULT_POWER_UP_KEY

	# If custom keybinds are saved, then load custom values
	else:
		match action:
			keybind_resource.SHOOT:
				return keybind_resource.shoot
			keybind_resource.POWER_UP:
				return keybind_resource.power_up
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.MOVE_UP:
				return keybind_resource.move_up_key
			keybind_resource.MOVE_DOWN:
				return keybind_resource.move_down_key
			keybind_resource.SHOOT_KEY:
				return keybind_resource.shoot_key
			keybind_resource.POWER_UP_KEY:
				return keybind_resource.power_up_key

func reset_keybinds() -> void:
	keybind_resource.shoot = keybind_resource.DEFAULT_SHOOT
	keybind_resource.power_up = keybind_resource.DEFAULT_POWER_UP
	keybind_resource.move_left_key = keybind_resource.DEFAULT_MOVE_LEFT_KEY
	keybind_resource.move_right_key = keybind_resource.DEFAULT_MOVE_RIGHT_KEY
	keybind_resource.move_up_key = keybind_resource.DEFAULT_MOVE_UP_KEY
	keybind_resource.move_down_key = keybind_resource.DEFAULT_MOVE_DOWN_KEY
	keybind_resource.shoot_key = keybind_resource.DEFAULT_SHOOT_KEY
	keybind_resource.power_up_key = keybind_resource.DEFAULT_POWER_UP_KEY
	
func on_keybinds_loaded(data : Dictionary) -> void:
	#Declare variables
	var loaded_shoot = InputEventMouseButton.new()
	var loaded_power_up = InputEventMouseButton.new()
	var loaded_move_left = InputEventKey.new()
	var loaded_move_right = InputEventKey.new()
	var loaded_move_up = InputEventKey.new()
	var loaded_move_down = InputEventKey.new()
	var loaded_shoot_key = InputEventKey.new()
	var loaded_power_up_key = InputEventKey.new()
	
	#Set variables to physical keys
	loaded_shoot.button_index = int(data.shoot)
	loaded_power_up.button_index = int(data.power_up)
	loaded_move_left.set_physical_keycode(int(data.move_left))
	loaded_move_right.set_physical_keycode(int(data.move_right))
	loaded_move_up.set_physical_keycode(int(data.move_up))
	loaded_move_down.set_physical_keycode(int(data.move_down))
	loaded_shoot_key.set_physical_keycode(int(data.shoot_key))
	loaded_power_up_key.set_physical_keycode(int(data.power_up_key))

	#Import physical key variables into keybind resource
	keybind_resource.shoot = loaded_shoot
	keybind_resource.power_up = loaded_power_up
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.move_up_key = loaded_move_up
	keybind_resource.move_down_key = loaded_move_down
	keybind_resource.shoot_key = loaded_shoot_key
	keybind_resource.power_up_key = loaded_power_up_key

	#Run a check to make sure keybinds have an option loaded to them.
	check_for_null_keybinds()
	# Keep these vaules as default until I can figure out how to properly load button index
	
	
func check_for_null_keybinds() -> void:
	#Run a check to make sure keybinds have an option loaded to them.
	if keybind_resource.shoot.to_string() == "(Unset)":
		keybind_resource.shoot = keybind_resource.DEFAULT_SHOOT
	if keybind_resource.power_up.to_string() == "(Unset)":
		keybind_resource.power_up = keybind_resource.DEFAULT_POWER_UP
	if keybind_resource.move_left_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.move_left_key = keybind_resource.DEFAULT_MOVE_LEFT_KEY
	if keybind_resource.move_right_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.move_right_key = keybind_resource.DEFAULT_MOVE_RIGHT_KEY
	if keybind_resource.move_up_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.move_up_key = keybind_resource.DEFAULT_MOVE_UP_KEY
	if keybind_resource.move_down_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.move_down_key = keybind_resource.DEFAULT_MOVE_DOWN_KEY
	if keybind_resource.shoot_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.shoot_key = keybind_resource.DEFAULT_SHOOT_KEY
	if keybind_resource.power_up_key.as_text_physical_keycode() == "(Unset)":
		keybind_resource.power_up_key = keybind_resource.DEFAULT_POWER_UP_KEY
	
func on_settings_data_loaded(data: Dictionary) -> void:
	loaded_data = data
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_selected(loaded_data.resolution_index)
	on_master_sound_set(loaded_data.master_volume_index)
	on_music_sound_set(loaded_data.music_volume_index)
	on_sfx_sound_set(loaded_data.sfx_volume_index)
	on_subtitles_toggled(loaded_data.subtitles_set)
	on_autofire_toggled(loaded_data.autofire_set)
	#on_keybinds_loaded(loaded_data.keybinds)
	
func handle_signals() -> void:
	print("data container signals set")
	#Window mode
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_resolution_selected)

	#Audio
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	
	#General/Accessiblity/Advance Options
	SettingsSignalBus.on_subtitles_toggled.connect(on_subtitles_toggled)
	SettingsSignalBus.on_autofire_toggled.connect(on_autofire_toggled)
	
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
	loaded_data = {} #Empty Dictonary after use for optimization
