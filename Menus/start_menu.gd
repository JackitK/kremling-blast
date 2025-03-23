extends CenterContainer

@onready var start_game_button: Button = %StartGameButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var main_menu: MarginContainer = %MainMenu
@onready var music_player: AudioStreamPlayer2D = %music_player
@onready var high_score_label: Label = $MainMenu/VBoxContainer/high_score_label


@export var options_menu = preload("res://Menus/Options Menu/Options_Menu.tscn") as PackedScene
@export var start_level = preload("res://levels/level1.tscn") as PackedScene

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()
	handle_connecting_signals()
	load_opening_data()
	load_audio_settings_for_start_menu()
	
	music_player.play()
	
	var high_score:int = SaveManager.save_data.high_score
	high_score_label.text = "High Score: " + str(high_score)

	
func game_start_pressed() -> void:
	await LevelTransition.fade_to_black()
	load_level_data()
	get_tree().change_scene_to_packed(start_level)
	LevelTransition.fade_from_back()
	load_audio_settings()
	
func on_options_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(options_menu)
	LevelTransition.fade_from_back()
	
func quit_game_pressed() -> void:
	get_tree().quit()

func handle_connecting_signals() -> void:
	start_game_button.button_down.connect(game_start_pressed)
	quit_button.button_down.connect(quit_game_pressed)
	options_button.button_down.connect(on_options_pressed)

func load_opening_data() -> void:
	SaveManager.load_settings_data()
	load_audio_settings()

func load_level_data() -> void:
	pass
	#start_level = LevelData.load_level_from_index()
	
func load_audio_settings() -> void:
	var master_vl = linear_to_db(SettingsDataContainer.get_master_sound())
	var music_vl = linear_to_db(SettingsDataContainer.get_music_sound())
	var sfx_vl = linear_to_db(SettingsDataContainer.get_sfx_sound())
	
	AudioServer.set_bus_volume_db(0, master_vl)
	AudioServer.set_bus_volume_db(1, music_vl)
	AudioServer.set_bus_volume_db(2, sfx_vl)

func load_audio_settings_for_start_menu() -> void:
	pass
	#var master_vl = linear_to_db(SettingsDataContainer.get_master_sound())
	#AudioServer.set_bus_volume_db(0, master_vl)
	#var music_vl = linear_to_db(SettingsDataContainer.get_music_sound())
	#AudioServer.set_bus_volume_db(1, music_vl)
