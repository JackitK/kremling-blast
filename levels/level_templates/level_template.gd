class_name Level
extends Node2D
@export var next_level: PackedScene = null

@onready var baddy: Node2D = %baddy
var score: int = 0
@onready var coconut_gun: AudioStreamPlayer = %CoconutGun
@onready var score_display: Control = %Score
@onready var pop_up_message: Label = %pop_up_message
@onready var victory_theme: AudioStreamPlayer2D = %victory_theme
@onready var banana_counter: Node2D = $level_ui/banana_count
@onready var level_track: AudioStreamPlayer2D = $audio_player/level_track
@onready var baddy_left_meter: Node2D = %BaddyLeftMeter
@onready var miss_counter: Node2D = %MissCounter


@onready var autofire_timer: Timer = %autofire_timer
@onready var gameover_timer: Timer = %gameover_timer


signal enemy_hit
signal ally_hit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = Events.total_score
	score_display.score_count.text = str(score)
	hide_unused_counters()
	Events.enemy_hit.connect(shot_event)
	Events.ally_hit.connect(hurt_friend_event)
	Events.level_cleared.connect(level_cleared_event)
	Events.game_over.connect(game_over_event)
	if SettingsDataContainer.autofire_state == true:
		autofire_timer.autostart = true
		autofire_timer.start()
	Events.shot_triggered.connect(play_the_gun)
	gameover_timer.timeout.connect(back_to_startmenu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_input_check()

func shot_event(value:int):
	score += value
	score_display.score_count.text = str(score)
	print (score)
	
func hurt_friend_event(value:int):
	score -= value
	if score <= 0:
		score = 0
	score_display.score_count.text = str(score)
	print (score)

func level_cleared_event():
	print("level cleared)")
	level_track.stop()
	pop_up_message.set_deferred("visible", true)
	pop_up_message.text = "Level Cleared!"
	get_tree().paused = true
	victory_theme.play()
	
	
func game_over_event():
	pop_up_message.set_deferred("visible", true)
	pop_up_message.text = "Game Over"
	level_track.stop()
	get_tree().paused = true
	gameover_timer.start(5.0)

func go_to_next_level():
	print("heading into next level")
	Events.total_score += score
	if next_level is PackedScene:
		get_tree().change_scene_to_packed(next_level)
	else:
		back_to_startmenu()
func back_to_startmenu():
	track_highscore()
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")

func _on_victory_theme_finished() -> void:
	print("theme finished")
	get_tree().paused = false
	go_to_next_level()

func play_the_gun() -> void:
	coconut_gun.play()

func _on_autofire_timeout() -> void:
	if Input.is_action_pressed("shoot"):
		print("autofire held")
		Events.emit_shot_triggered()
		
func player_input_check() -> void:
	if Input.is_action_just_pressed("shoot") and SettingsDataContainer.autofire_state == false:
		Events.emit_shot_triggered()
		print("shoot button pressed")
	elif Input.is_action_just_pressed("power_up"):
		if banana_counter.get_banana_count() > 0:
			Events.emit_power_up()
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	cheat_check()
	
func cheat_check () -> void:
	if Input.is_action_just_pressed("banana cheat"):
		Events.emit_banana_tally(1)
		if banana_counter.visible == false:
			banana_counter.visible = true
	if Input.is_action_just_pressed("autofire_toggle"):
		if SettingsDataContainer.autofire_state == false:
			SettingsDataContainer.autofire_state = true
			print("autofire toggled on")
			autofire_timer.autostart = true
			autofire_timer.start()
		else:
			SettingsDataContainer.autofire_state = false
			print("autofire toggled off")
			autofire_timer.stop()

func hide_unused_counters() -> void:
	var ban_count = get_tree().get_nodes_in_group("banana").size()
	print("banana count " + str(ban_count))
	if ban_count <= 1:
		banana_counter.visible = false
		
func track_highscore() -> void:
	var play_session_score: int = Events.total_score
	var best_score = SaveManager.save_data.high_score
	print("High Score: " + str(best_score))
	print("Current Score: "+ str(play_session_score))
	if play_session_score > best_score:
		SaveManager.save_data.high_score = play_session_score
		SaveManager.save_data.save()
