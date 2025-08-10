extends CenterContainer

@onready var start_game_button: Button = %StartGameButton
@onready var load_game_button: Button = %LoadGameButton
@onready var level_select_button: Button = %LevelSelectButton
@onready var options_button: Button = %OptionsButton
@onready var chaos_button: Button = %ChaosGameButton
@onready var quit_button: Button = %QuitButton
@onready var main_menu: MarginContainer = %MainMenu
@onready var music_player: AudioStreamPlayer2D = %music_player
@onready var high_score_label: Label = $MainMenu/VBoxContainer/high_score_label
@onready var endless_score_label: Label = $MainMenu/VBoxContainer/endless_score_label


@export var options_menu = preload("res://Menus/Options Menu/Options_Menu.tscn") as PackedScene
@export var start_level = preload("res://levels/cutscene_1.tscn") as PackedScene
@export var endless_level = preload("res://levels/chaos_mode.tscn") as PackedScene
@export var level_select = preload("res://Menus/level_select.tscn") as PackedScene

@onready var welcome_template = preload("res://Menus/Options Menu/welcome_screen.tscn")
var welcome_screen:ConfirmContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	start_game_button.grab_focus()
	handle_connecting_signals()
	load_opening_data()
	SaveData.load_or_create()
	LastSavedLevelData.load_or_create()
	music_player.play()
	
	var high_score:int = SaveManager.save_data.high_score
	var chaos_score:int = SaveManager.save_data.endless_score
	print("chaos score: " + str(chaos_score))
	high_score_label.text = "High Score: " + str(high_score)
	endless_score_label.text = "Chaos Score: " + str(chaos_score)
	if high_score == 0:
		high_score_label.visible = false
	else:
		high_score_label.visible = true
	if chaos_score == 0:
		endless_score_label.visible = false
	else:
		endless_score_label.visible = true
	handle_hiding_elements()
		
func game_start_pressed() -> void:
	await LevelTransition.fade_to_black()
	handle_challenge_modifiers()
	get_tree().change_scene_to_packed(start_level)
	LevelTransition.fade_from_back()
	load_audio_settings()
	
func on_options_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(options_menu)
	LevelTransition.fade_from_back()
	
func load_past_game():
	Events.total_score = SaveManager.last_saved_lv.current_score
	var loaded_level_path = SaveManager.last_saved_lv.current_level
	SettingsDataContainer.difficulty = SaveManager.last_saved_lv.saved_difficulty
	SettingsDataContainer.lives_type = SaveManager.last_saved_lv.saved_lives_mode
	#If in endurance mode, load up the saved life count as well
	if SaveManager.last_saved_lv.saved_lives_mode == 1:
		Events.global_lives = SaveManager.last_saved_lv.saved_life_count
	var loaded_level = load(loaded_level_path)
	if loaded_level != null:
		start_level = loaded_level
	#Start the game
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(start_level)
	LevelTransition.fade_from_back()
	load_audio_settings()
	
func endless_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(endless_level)
	LevelTransition.fade_from_back()
	
func level_select_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(level_select)
	LevelTransition.fade_from_back()
	
func quit_game_pressed() -> void:
	get_tree().quit()

func handle_connecting_signals() -> void:
	start_game_button.button_down.connect(game_start_pressed)
	quit_button.button_down.connect(quit_game_pressed)
	chaos_button.button_down.connect(endless_pressed)
	options_button.button_down.connect(on_options_pressed)
	load_game_button.button_down.connect(load_past_game)
	level_select_button.button_down.connect(level_select_pressed)

func handle_hiding_elements() -> void:
	if SaveManager.last_saved_lv.current_level == "":
		load_game_button.visible = false
	print("Campaign beaten:")
	print(SettingsDataContainer.campaign_beat)
	if SettingsDataContainer.campaign_beat == false:
		level_select_button.visible = false

func load_opening_data() -> void:
	SaveManager.load_settings_data()
	check_for_mobile()
	load_audio_settings()
	load_graphics_settings()
	set_custom_cursor()
	
func load_audio_settings() -> void:
	var master_vl = linear_to_db(SettingsDataContainer.get_master_sound())
	var music_vl = linear_to_db(SettingsDataContainer.get_music_sound())
	var sfx_vl = linear_to_db(SettingsDataContainer.get_sfx_sound())
	
	AudioServer.set_bus_volume_db(0, master_vl)
	AudioServer.set_bus_volume_db(1, music_vl)
	AudioServer.set_bus_volume_db(2, sfx_vl)

func load_graphics_settings() -> void:
	var window_index : int = SettingsDataContainer.window_mode_index
	match window_index:
		0: #window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #Borderless Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: #Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	
	const STARTING_RESOLUTION_DICTIONARY : Dictionary = {
	"1152 x 648" : Vector2i(1152, 648),
	"960 x 540" : Vector2i(960, 540),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1080" : Vector2i(1920, 1080)
	}
	
	var resolution_index : int = SettingsDataContainer.resolution_index
	DisplayServer.window_set_size(STARTING_RESOLUTION_DICTIONARY.values()[resolution_index])

func handle_challenge_modifiers()-> void:
	var diff:int = SettingsDataContainer.get_difficulty()
	var lives:int = SettingsDataContainer.get_lives_type()
	
	# Update starting game data based on difficulty selected
	# Some features will have to be applied directly to the functions and can't be set here
	match diff:
		0: #Easy
			Events.global_lives = 30
		1: #Normal
			Events.global_lives = 20
		2: #Hard
			Events.global_lives = 5
			
	match lives:
		0: #Fixed per level
			pass
		1: #Endurance (Lives carry over between levels)
			pass
		
func set_custom_cursor() -> void:
	if SettingsDataContainer.custom_cursor:
		Input.set_custom_mouse_cursor(preload("res://sprite/crosshairs.png"), 0, Vector2(16,16))
	else:
		Input.set_custom_mouse_cursor(null)

func check_for_mobile() -> void:
	if OS.has_feature("mobile") || DisplayServer.is_touchscreen_available():
		SettingsDataContainer.mobile_buttons = true
		if Events.has_mobile_warning_been_displayed == false:
			Events.has_mobile_warning_been_displayed = true
			mobile_welcome("welcome")
		

func mobile_welcome(type:String) -> void:
	if not welcome_screen:
		welcome_screen = welcome_template.instantiate()
		welcome_screen.confirmation_type = type
		canvas_layer.add_child(welcome_screen)
