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

@onready var best_clear_fixed: CanvasLayer = %best_clear_fixed
@onready var fixed_clear_label: Label = $best_clear_fixed/best_clear_label
@onready var medal_fixed_sprite: Sprite2D = $best_clear_fixed/medal_fixed
@onready var best_clear_endure: CanvasLayer = %best_clear_endure
@onready var endure_clear_label: Label = $best_clear_endure/best_clear_label
@onready var medal_endure_sprite: Sprite2D = $best_clear_endure/medal_fixed



@export var options_menu = preload("res://Menus/Options Menu/Options_Menu.tscn") as PackedScene
@export var start_level = preload("res://levels/cutscenes/cutscene_1.tscn") as PackedScene
@export var endless_level = preload("res://levels/chaos_mode.tscn") as PackedScene
@export var level_select = preload("res://Menus/level_select.tscn") as PackedScene
@export var credits = preload("res://Menus/credits_screen.tscn") as PackedScene

@onready var welcome_template = preload("res://Menus/Options Menu/welcome_screen.tscn")
var welcome_screen:ConfirmContainer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _process(delta: float) -> void:
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			AudioServer.set_bus_mute(0, true)
		NOTIFICATION_APPLICATION_FOCUS_IN:
			AudioServer.set_bus_mute(0, false)

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
	if SaveManager.save_data.diff_base == null:
		SaveManager.save_data.diff_base = ""
	if SaveManager.save_data.diff_endless == null:
		SaveManager.save_data.diff_base = ""
	
	high_score_label.text = "High Score: " + str(high_score)  + " " + SaveManager.save_data.diff_base
	endless_score_label.text = "Chaos Score: " + str(chaos_score) + " " + SaveManager.save_data.diff_endless
	if high_score == 0:
		high_score_label.visible = false
	else:
		high_score_label.visible = true
	if chaos_score == 0:
		endless_score_label.visible = false
	else:
		endless_score_label.visible = true
	handle_banana_medals()
	handle_hiding_elements()
		
	if OS.has_feature("web"):
		quit_button.visible = false
		
func game_start_pressed() -> void:
	await LevelTransition.fade_to_black()
	handle_challenge_modifiers()
	get_tree().change_scene_to_packed(start_level)
	LevelTransition.fade_from_back()
	Events.load_audio_settings()
	
func on_options_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(options_menu)
	LevelTransition.fade_from_back()
	
func load_past_game():
	# Load saved level and score
	Events.total_score = SaveManager.last_saved_lv.current_score
	var loaded_level_path = SaveManager.last_saved_lv.current_level
	#Load up difficulty and game mode/lives type
	SettingsDataContainer.difficulty = SaveManager.last_saved_lv.saved_difficulty
	SettingsDataContainer.lives_type = SaveManager.last_saved_lv.saved_lives_mode
	#If in endurance mode, load up the saved life count as well
	if SaveManager.last_saved_lv.saved_lives_mode == 1:
		Events.global_lives = SaveManager.last_saved_lv.saved_life_count
	# If player used level select to start game, reapply that tag
	Events.level_select_used = SaveManager.last_saved_lv.level_select_used
	
	#load level
	var loaded_level = load(loaded_level_path)
	if loaded_level != null:
		start_level = loaded_level
	
	#Start the game
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(start_level)
	LevelTransition.fade_from_back()
	Events.load_audio_settings()
	
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
	if SettingsDataContainer.campaign_beat == false:
		level_select_button.visible = false

func load_opening_data() -> void:
	SaveManager.load_settings_data()
	check_for_mobile()
	Events.load_audio_settings()
	Events.load_graphics_settings()
	set_custom_cursor()

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


func _on_credits_button_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(credits)
	LevelTransition.fade_from_back()

func handle_banana_medals() -> void:
	# Handle fixed lives campaign
	if SaveManager.save_data.best_campaign_win_fixed == "":
		best_clear_fixed.visible = false
	else:
		best_clear_fixed.visible = true
		match SaveManager.save_data.best_campaign_win_fixed:
			"Easy":
				medal_fixed_sprite.texture = load("res://sprite/banana_medals/easy_fixed.png")
				fixed_clear_label.text = "Easy"
			"Normal":
				medal_fixed_sprite.texture = load("res://sprite/banana_medals/normal_fixed.png")
				fixed_clear_label.text = "Normal"
			"Hard":
				medal_fixed_sprite.texture = load("res://sprite/banana_medals/hard_fixed.png")
				fixed_clear_label.text = "Hard"
	# Handle endure lives campaign
	if SaveManager.save_data.best_campaign_win_endure == "":
		best_clear_endure.visible = false
	else:
		best_clear_endure.visible = true
		match SaveManager.save_data.best_campaign_win_endure:
			"Easy":
				medal_endure_sprite.texture = load("res://sprite/banana_medals/easy_endurance.png")
				endure_clear_label.text = "Easy"
			"Normal":
				medal_endure_sprite.texture = load("res://sprite/banana_medals/normal_endurance.png")
				endure_clear_label.text = "Normal"
			"Hard":
				medal_endure_sprite.texture = load("res://sprite/banana_medals/hard_endurance.png")
				endure_clear_label.text = "Hard"
