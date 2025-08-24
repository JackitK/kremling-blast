class_name Level
extends Node2D
@export var next_level: PackedScene = null
@export var spawn_point:Vector2 = Vector2(500.0, 500.0)
@export var time_bonus:int = 50.0
@export var is_boss_stage:bool = false

var score: int = 0
var starting_score:int = 0
var game_over_state:bool = false
@onready var coconut_gun: AudioStreamPlayer = %CoconutGun
@onready var score_display: Control = %Score
@onready var level_prompt: ColorRect = %prompt_box
@onready var pop_up_message: Label = %pop_up_message
@onready var b_score_message: Label = %bonus_time_message
@onready var victory_theme: AudioStreamPlayer2D = %victory_theme
@onready var banana_counter: Node2D = %banana_count
@onready var level_track: AudioStreamPlayer2D = $audio_player/level_track
@onready var baddy_left_meter: BaddyLeftMeter = %BaddyLeftMeter
@onready var miss_counter: Miss_Counter = %MissCounter
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

@onready var confirm_prompt = preload("res://Menus/Options Menu/confirmation_container.tscn")
var confirm_message:ConfirmContainer
@onready var confirm_canvas: CanvasLayer = $CanvasLayer

var kong_selection_box
var kong_selection:String = ""
@onready var kong_select_loadout = preload("res://Menus/kong_selection_tab.tscn")
@onready var kong_canvas: CanvasLayer = $CanvasLayer

@onready var autofire_timer: Timer = %autofire_timer
@onready var gameover_timer: Timer = %gameover_timer
@onready var time_bonus_ticker: Timer = $timers/time_bonus_ticker
@onready var pause_delay_timer: Timer = $timers/pause_delay_timer


@onready var kong_button: KongButton = %"Kong Button"
@onready var touch_options: CanvasLayer = %touch_options


var autofire_ticker: float = 0.5
var click_quque: bool = false
var is_pause_delay = false

signal enemy_hit
signal ally_hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	difficulty_adjustments()
	miss_counter.update_miss_counter()
	score = Events.total_score
	starting_score = score
	score_display.score_count.text = str(score)
	score_display.bonus_time_label.text = "Bonus: " + str(time_bonus)
	hide_unused_counters()
	Events.score_tally.connect(score_event)
	Events.current_score_update.connect(update_score_globally)
	Events.ally_hit.connect(hurt_friend_event)
	Events.level_cleared.connect(level_cleared_event)
	Events.game_over.connect(game_over_event)
	setup_autofire()
	set_mobile_mode()
	if level_has_hero_kongs() == false:
		kong_button.visible = false
	Events.shot_triggered.connect(play_the_gun)
	Events.back_to_start_menu.connect(back_to_startmenu)
	Events.save_the_game.connect(save_current_game_progress)
	gameover_timer.timeout.connect(back_to_startmenu)
	Events.will_you_continue.connect(handle_continue_message_response)
	Events.kong_selection.connect(confirm_kongfirmation)
	Events.pause_prompt.connect(_on_prompt_pause_button_pressed)
	Events.kong_button_prompt.connect(kong_mobile_button_pressed)
	Events.live_update_settings.connect(on_fly_options_update)
	Events.stop_sounds.connect(stop_all_sounds)
	Events.pause_delay.connect(set_pause_delay)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	player_input_check()
	cheat_check()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			AudioServer.set_bus_mute(0, true)
			if get_tree().paused == false:
				pause_menu.pause()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			AudioServer.set_bus_mute(0, false)
		NOTIFICATION_APPLICATION_PAUSED:
			AudioServer.set_bus_mute(0, true)
			if get_tree().paused == false:
				pause_menu.pause()

func score_event(value:int):
	score += value
	score_display.score_count.text = str(score)
	
func hurt_friend_event(value:int):
	score -= value
	if score <= 0:
		score = 0
	score_display.score_count.text = str(score)

func return_level_name() -> String:
	var level_name:String
	return self.resource_path

func save_current_game_progress() -> void:
	var level_path:String = get_scene_file_path()
	SaveManager.last_saved_lv.current_level = level_path
	SaveManager.last_saved_lv.current_score = starting_score
	SaveManager.last_saved_lv.saved_difficulty = SettingsDataContainer.difficulty
	SaveManager.last_saved_lv.saved_lives_mode = SettingsDataContainer.lives_type
	if SettingsDataContainer.difficulty == 1:
		SaveManager.last_saved_lv.saved_life_count = Events.global_lives
	SaveManager.last_saved_lv.level_select_used = 	Events.level_select_used
	SaveManager.last_saved_lv.save()

func level_cleared_event():
	Events.emit_stop_sounds()
	level_prompt.set_deferred("visible", true)
	pop_up_message.text = "Level Cleared!"
	implement_time_bonus()
	get_tree().paused = true
	if not victory_theme.playing:
		victory_theme.play()
	
	
func game_over_event():
	level_prompt.set_deferred("visible", true)
	pop_up_message.set_deferred("visible", true)
	pop_up_message.text = "Game Over"
	game_over_state = true
	level_track.stop()
	if SettingsDataContainer.difficulty < 2:
		show_confirmation_prompt("continue_game")
	else:
		gameover_timer.start(2)
	get_tree().paused = true
	
func handle_continue_message_response(state:bool) -> void:
	# If true handle continue conditions and restart level
	if state:
		score = starting_score
		score /= 2
		Events.total_score = score
		get_tree().paused = false
		get_tree().reload_current_scene()
	# If false, complete game over and boot back to main menu
	else:
		confirm_game_over()
	
func confirm_game_over():
	clear_save_progress_data()
	back_to_startmenu()

func go_to_next_level():
	Events.set_score(score)
	print("score " + str(Events.total_score))
	#If lives endurance mode is set, update global lives to the current miss count
	if self is not Bonus_Level: 
		print("current level isn't a bonus")
		print(SettingsDataContainer.lives_type)
		if SettingsDataContainer.lives_type == 1:
			print("Update global lives")
			Events.global_lives = miss_counter.miss_count
	
	if next_level is PackedScene:
		get_tree().change_scene_to_packed(next_level)
	else:
		get_tree().change_scene_to_file("res://levels/cutscenes/credits.tscn")
func back_to_startmenu():
	Events.total_score = score
	if self is One_off_Level:
		track_highscore()
	else:
		if game_over_state == false:
			save_current_game_progress()
		else:
			track_highscore()
			clear_save_progress_data()
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	Events.total_score = 0


func _on_victory_theme_finished() -> void:
	get_tree().paused = false
	go_to_next_level()

func play_the_gun() -> void:
	coconut_gun.play()

func _on_autofire_timeout() -> void:
	if Input.is_action_pressed("shoot"):
		Events.emit_shot_triggered()
		
func player_input_check() -> void:
	if Input.is_action_just_pressed("shoot") and SettingsDataContainer.autofire_state == false:
		if click_quque == false and is_pause_delay == false:
			Events.emit_shot_triggered()
	elif Input.is_action_just_pressed("power_up"):
		triggering_kong_power(false)
	elif Input.is_action_pressed("ui_cancel"):
		"cancel ui pressed"
		pass
	
func cheat_check () -> void:
	if OS.is_debug_build() == false:
		return
	if Input.is_action_just_pressed("clear_lv_select_flag") and Input.is_action_just_pressed("banana cheat"):
		level_cleared_event()
	if Input.is_action_just_pressed("banana cheat"):
		Events.emit_banana_tally(1)
		if banana_counter.visible == false:
			banana_counter.visible = true
	if Input.is_action_just_pressed("autofire_toggle"):
		if SettingsDataContainer.autofire_state == false:
			SettingsDataContainer.autofire_state = true
			autofire_timer.autostart = true
			autofire_timer.start()
		else:
			SettingsDataContainer.autofire_state = false
			autofire_timer.stop()
	if Input.is_action_just_pressed("simple_kong_toggle"):
		if SettingsDataContainer.simplify_kong_rate == false:
			SettingsDataContainer.simplify_kong_rate = true
		else:
			SettingsDataContainer.simplify_kong_rate = false
	if Input.is_action_just_pressed("clear_lv_select_flag"):
		Events.level_select_used = false
	
func hide_unused_counters() -> void:
	var ban_count = get_tree().get_nodes_in_group("banana").size()
	if ban_count <= 1:
		banana_counter.visible = false
	if self is Bonus_Level:
		score_display.bonus_time_label.visible = false

func update_score_globally() -> void:
	Events.set_score(score)
	
func track_highscore() -> void:
	var play_session_score: int = Events.total_score
	var best_score = SaveManager.save_data.high_score
	
	var mode:String
	match SettingsDataContainer.difficulty:
		0:
			mode = "(Easy)"
		1:
			mode = "(Normal)"
		2:
			mode = "(Hard)"
		_:
			""
	
	if play_session_score > best_score:
		SaveManager.save_data.high_score = play_session_score
		SaveManager.save_data.diff_base = mode
		SaveManager.save_data.save()

func setup_autofire() -> void:
	autofire_ticker = SettingsDataContainer.autofire_rate
	autofire_timer.wait_time = autofire_ticker
	if SettingsDataContainer.autofire_state == true:
		autofire_timer.autostart = true
		autofire_timer.start()
	else:
		autofire_timer.autostart = false
		autofire_timer.stop()

func implement_time_bonus()->void:
	score += time_bonus
	b_score_message.set_deferred("visible", true)
	b_score_message.text = "Time Bonus: " + str(time_bonus)
	

func _on_time_bonus_ticker_timeout() -> void:
	time_bonus -= 1
	if time_bonus <= 0:
		time_bonus = 0
		time_bonus_ticker.stop()
	else:
		time_bonus_ticker.start()
	score_display.bonus_time_label.text = "Bonus: " + str(time_bonus)


func triggering_kong_power(kong_button_prompted:bool) -> void:
	if SettingsDataContainer.simplify_kong_rate == true or (touch_options.visible == true and kong_button_prompted):
		var kong_stash = get_tree().get_nodes_in_group("good_guys")
		var hero_kongs: Array[Kong]
		for node in kong_stash:
			if node is DonkeyKong || node is DiddyKong || node is LankyKong || node is TinyKong || node is ChunkyKong:
				hero_kongs.append(node)
		var number_of_heroes = hero_kongs.size()
		if banana_counter.get_banana_count() > 0:
			if number_of_heroes == 1:
				hero_kongs[0].kong_power()
			elif number_of_heroes > 1:
				get_tree().paused = true
				show_kongfirmation_prompt(hero_kongs)
			else:
				pass
	else:
		if banana_counter.get_banana_count() > 0:
			Events.emit_power_up()

func show_kongfirmation_prompt(hero_kongs) -> void:
	if not kong_selection_box:
		#Display box:
		kong_selection_box = kong_select_loadout.instantiate()
		kong_canvas.add_child(kong_selection_box)
		
		#Determine which Kongs are in level and hide any Kongs that don't appear from the selection:
		var kong_lib:Dictionary  = {
			"DK":false,
			"Diddy": false,
			"Lanky": false,
			"Tiny": false,
			"Chunky": false
			
		}
		
		for node in hero_kongs:
			if node is DonkeyKong:
				kong_lib.DK = true
			elif node is DiddyKong:
				kong_lib.Diddy = true
			elif node is LankyKong:
				kong_lib.Lanky = true
			elif node is TinyKong:
				kong_lib.Tiny = true
			elif node is ChunkyKong:
				kong_lib.Chunky = true
		if kong_lib.DK == false:
			kong_selection_box.donkey.visible = false
		if kong_lib.Diddy == false:
			kong_selection_box.diddy.visible = false
		if kong_lib.Lanky == false:
			kong_selection_box.lanky.visible = false
		if kong_lib.Tiny == false:
			kong_selection_box.tiny.visible = false
		if kong_lib.Chunky == false:
			kong_selection_box.chunky.visible = false

func confirm_kongfirmation(kong_selected) -> void:
	var kong_stash = get_tree().get_nodes_in_group("good_guys")
	match kong_selected:
		"DonkeyKong":
			for node in kong_stash:
				if node is DonkeyKong:
					node.kong_power()
					return	
		"DiddyKong":
			for node in kong_stash:
				if node is DiddyKong:
					node.kong_power()
					return	
		"LankyKong":
			for node in kong_stash:
				if node is LankyKong:
					node.kong_power()
					return	
		"TinyKong":
			for node in kong_stash:
				if node is TinyKong:
					node.kong_power()
					return	
		"ChunkyKong":
			for node in kong_stash:
				if node is ChunkyKong:
					node.kong_power()
					return	
	
func clear_save_progress_data() -> void:
	var dir = DirAccess.open("user://save_data.tres")
	SaveManager.last_saved_lv = LastSavedLevelData.new()
	SaveManager.last_saved_lv.save()
	
func show_confirmation_prompt(type:String) -> void:
	if not confirm_message:
		confirm_message = confirm_prompt.instantiate()
		confirm_message.confirmation_type = type
		confirm_canvas.add_child(confirm_message)
		
func difficulty_adjustments() -> void:
	print("set difficulty adjustments")
	
	match SettingsDataContainer.difficulty:
			0: #Easy
				if is_boss_stage and baddy_left_meter.baddy_count_max > 5:
					baddy_left_meter.baddy_count_max -= 2
			1: #Normal
				pass
			2: #Hard
				if is_boss_stage:
					baddy_left_meter.baddy_count_max += 5
					baddy_left_meter.baddy_left_count += 5
					baddy_left_meter.set_progress_bar() 
	
	if SettingsDataContainer.lives_type == 1:
		print("set current lives to global lives of")
		print(Events.global_lives)
		miss_counter.miss_count = Events.global_lives
	else:
		match SettingsDataContainer.difficulty:
			0: #Easy
				miss_counter.miss_count += 5
			1: #Normal
				pass
			2: #Hard
				if miss_counter.miss_count > 2:
					miss_counter.miss_count -= 1

func set_mobile_mode() -> void:
	if SettingsDataContainer.mobile_buttons:
		touch_options.visible = true
	else:
		touch_options.visible = false

func _on_prompt_pause_button_pressed() -> void:
	if get_tree().paused == false:
		pause_menu.pause()

func kong_mobile_button_pressed() -> void:
	if kong_button.visible:
		if banana_counter.banana_count > 0:
			triggering_kong_power(true)
		else:
			kong_button.disclaim_signal.emit()
		
func level_has_hero_kongs() -> bool:
	var kong_stash = get_tree().get_nodes_in_group("good_guys")
	var hero_kongs: Array[Kong]
	for node in kong_stash:
		if node is DonkeyKong || node is DiddyKong || node is LankyKong || node is TinyKong || node is ChunkyKong:
			hero_kongs.append(node)
	var number_of_heroes = hero_kongs.size()
	if number_of_heroes > 0:
		return true
	else:
		return false

func temp_mobile_mode() -> void:
	touch_options.visible = true
	SettingsDataContainer.mobile_buttons = true

func on_fly_options_update() -> void:
	SaveManager.load_settings_data()
	setup_autofire()
	set_mobile_mode()
	Events.load_audio_settings()
	Events.load_graphics_settings()

func stop_all_sounds() -> void:
	level_track.stop()


func _on_skip_fanfare_button_pressed() -> void:
	if victory_theme.playing == true:
		victory_theme.stop()
		_on_victory_theme_finished()

# used to disable clicks/taps that happen the moment the game unpauses
func set_pause_delay() -> void:
	is_pause_delay = true
	pause_delay_timer.start()


func _on_pause_delay_timer_timeout() -> void:
	is_pause_delay = false
