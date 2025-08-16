extends Node

@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://Background Data/Resources/Settings/Default_Settings.tres")
@onready var keybind_resource : PlayerKeybindResource = preload("res://Background Data/Resources/Settings/PlayerKeybindDefault.tres")

var subtitles_state : bool = false
var autofire_state : bool = false
var autofire_rate: float = 0.5
var simplify_kong_rate: bool = false
var campaign_beat : bool = false
var difficulty: int = 1
var lives_type: int = 0
var custom_cursor: bool = true
var mobile_buttons: bool = false

var window_mode_index : int = 0
var resolution_index : int = 0

var master_volume: float = 0.0
var music_volume: float = 0.0
var sfx_volume: float = 0.0
var gun_volume: float = 0.0

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
		"gun_volume_index" : gun_volume,
		"subtitles_set" : subtitles_state,
		"autofire_set" : autofire_state,
		"autofire_rate" : autofire_rate,
		"simplify_kong_rate" : simplify_kong_rate,
		"campaign_beat" : campaign_beat,
		"difficulty" : difficulty,
		"lives_type" : lives_type,
		"custom_cursor" : custom_cursor,
		"mobile_buttons" : mobile_buttons
	}
	return settings_container_dict

func create_highscore_dictionary() -> Dictionary:
	var highscore_dict = {
		"score 1" = 0,
		"score 2" = 0,
		"score 3" = 0,
		"score 4" = 0,
		"score 5" = 0
	}
	return highscore_dict

#Accessiblity/General options functions
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
		return DEFAULT_SETTINGS.DEFAULT_AUTOFIRE_SET
	return autofire_state
	
# Audio options functions (setting and receiving)
func on_autofire_rate_set(index : float) -> void:
	autofire_rate = index
	
func get_autofire_rate() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_AUTOFIRE_RATE
	return autofire_rate
	
func on_simplify_kong_rate(value: bool) -> void:
	simplify_kong_rate = value

func get_simplify_kong_rate() -> bool:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_SIMPLIFY_KONG_SET
	return simplify_kong_rate
	
func get_difficulty() -> int:
	if loaded_data == {}:
		return 1
	return difficulty
	
func on_difficulty(value: int) -> void:
	difficulty = value
	
func get_lives_type() -> int:
	if loaded_data == {}:
		return 0
	return lives_type
	
func on_lives_type(value:int) -> void:
	lives_type = value
	
func get_custom_cursor() -> bool:
	if loaded_data == {}:
		return true
	return custom_cursor
	
func on_custom_cursor(value: bool) -> void:
	custom_cursor = value
	
func get_mobile_buttons() -> bool:
	if loaded_data == {}:
		return false
	return mobile_buttons
	
func on_mobile_buttons(value: bool) -> void:
	mobile_buttons = value
	
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

func on_gun_sound_set(index: float) -> void:
	gun_volume = index
	
func get_gun_sound() -> float:
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_GUN_VOLUME_INDEX
	return gun_volume
	
# Non-option menu related settings: Such as those triggered after beating the main campagin:
func on_set_campaign_beaten(index: bool) -> void:
	campaign_beat = index

func on_settings_data_loaded(data: Dictionary) -> void:
	loaded_data = data
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_selected(loaded_data.resolution_index)
	on_master_sound_set(loaded_data.master_volume_index)
	on_music_sound_set(loaded_data.music_volume_index)
	on_sfx_sound_set(loaded_data.sfx_volume_index)
	on_gun_sound_set(loaded_data.gun_volume_index)
	on_subtitles_toggled(loaded_data.subtitles_set)
	on_autofire_toggled(loaded_data.autofire_set)
	on_autofire_rate_set(loaded_data.autofire_rate)
	on_simplify_kong_rate(loaded_data.simplify_kong_rate)
	on_set_campaign_beaten(loaded_data.campaign_beat)
	on_difficulty(loaded_data.difficulty)
	on_lives_type(loaded_data.lives_type)
	on_custom_cursor(loaded_data.custom_cursor)
	on_mobile_buttons(loaded_data.mobile_buttons)
	#on_keybinds_loaded(loaded_data.keybinds)

func default_settings_reset() -> void:
	autofire_rate = DefaultSettingsResource.DEFAULT_AUTOFIRE_RATE
	autofire_state = DefaultSettingsResource.DEFAULT_AUTOFIRE_SET
	simplify_kong_rate = DefaultSettingsResource.DEFAULT_SIMPLIFY_KONG_SET
	window_mode_index = DefaultSettingsResource.DEFAULT_WINDOW_MODE_INDEX
	resolution_index = DefaultSettingsResource.DEFAULT_RESOLUTION_INDEX
	master_volume = DefaultSettingsResource.DEFAULT_MASTER_VOLUME_INDEX
	music_volume = DefaultSettingsResource.DEFAULT_MUSIC_VOLUME_INDEX
	sfx_volume = DefaultSettingsResource.DEFAULT_SFX_VOLUME_INDEX
	gun_volume = DefaultSettingsResource.DEFAULT_GUN_VOLUME_INDEX
	difficulty = 1
	lives_type = 0
	custom_cursor = true
	mobile_buttons = false

func handle_signals() -> void:
	#Window mode
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_selected.connect(on_resolution_selected)

	#Audio
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	SettingsSignalBus.on_gun_sound_set.connect(on_gun_sound_set)
	
	#General Options
	SettingsSignalBus.on_subtitles_toggled.connect(on_subtitles_toggled)
	SettingsSignalBus.on_autofire_toggled.connect(on_autofire_toggled)
	SettingsSignalBus.on_autofire_rate_set.connect(on_autofire_rate_set)
	SettingsSignalBus.on_simplify_kong_rate_set.connect(on_simplify_kong_rate)
	SettingsSignalBus.on_difficulty_set.connect(on_difficulty)
	SettingsSignalBus.on_Lives_type_set.connect(on_lives_type)
	SettingsSignalBus.on_custom_cursor_toggled.connect(on_custom_cursor)
	SettingsSignalBus.on_mobile_buttons_toggled.connect(on_mobile_buttons)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
	#loaded_data = {} #Empty Dictonary after use for optimization
