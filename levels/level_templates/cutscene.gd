class_name Cutscene
extends Node2D

@export var next_level: PackedScene = null
@export var export_file_path: String = ""
@export var export_mobile_path = ""
@export var is_final_scene: bool = false
@onready var default_file_path = "res://Dialogue/cutscene_1.txt"
@onready var default_audio_path = "res://sounds/music/Cranky's Lab.mp3"
@onready var cutscene_dialouge_box: Label = %cutscene_dialouge_box
@onready var next_button: Button = %next_button
@onready var skip_button: Button = %skip_button
@onready var score_display_timer: Timer = $Score_display_timer
@onready var displaying_score: bool = false
@onready var music_player: AudioStreamPlayer2D = $music_player

var cutscene_dict: Dictionary = {}
var cutscene_array: PackedStringArray
var current_index: int = 0
var cutscene_max: int = 0
var cutscene_prop_array: Array[ImageSpawner] = []
var prop_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_and_store_dialouge_from_file()
	display_line()
	next_button.button_down.connect(next_line)
	skip_button.button_down.connect(go_to_next_level)
	prep_cutscene_items()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			AudioServer.set_bus_mute(0, true)
		NOTIFICATION_APPLICATION_FOCUS_IN:
			AudioServer.set_bus_mute(0, false)
			
func go_to_next_level():
	if displaying_score:
		back_to_startmenu()
		return
	
	if next_level is PackedScene:
		get_tree().change_scene_to_packed(next_level)
	else:
		if is_final_scene:
			track_highscore()
			clear_save_and_unlock_level_select()
			update_clear_medals()
		else:
			back_to_startmenu()

func load_and_store_dialouge_from_file():
	var filePath = ""
	if OS.has_feature("mobile") || DisplayServer.is_touchscreen_available():
		if export_mobile_path != "" and export_mobile_path != null:
			filePath = export_mobile_path
		elif export_file_path != "" and export_file_path != null:
			filePath = export_file_path
		else:
			filePath = default_file_path
	else:
		if export_file_path != "" and export_file_path != null:
			filePath = export_file_path
		else:
			filePath = default_file_path
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	cutscene_array = content.split("->",true, 0)
	cutscene_max = cutscene_array.size()
	file.close()

func display_line():
	var line:String = cutscene_array[current_index]
	if line.contains("[hide_all_props]"):
		line = line.replacen("[hide_all_props]", "")
		hide_all_props()
	if line.contains("[prop]"):
		line = line.replacen("[prop]", "")
		reveal_prop()
	if line.contains("[play]"):
		line = line.replacen("[play]", "")
		play_music()
	cutscene_dialouge_box.text = line

func next_line():
	if displaying_score:
		back_to_startmenu()
		return
	current_index += 1
	if current_index >= cutscene_max -1:
		go_to_next_level()
	else:
		display_line()
		


func back_to_startmenu():
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	Events.total_score = 0

func track_highscore() -> void:
	var play_session_score: int = Events.total_score
	var best_score = SaveManager.save_data.high_score
	display_highscore(play_session_score, best_score)
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
		
func display_highscore(session_score:int, high_score:int) -> void:
	displaying_score = true
	score_display_timer.wait_time = 10
	cutscene_dialouge_box.text = "High Score: " + str(high_score) +  "\nYour Score: "+ str(session_score)
	score_display_timer.start()
	
func _on_score_display_timer_timeout() -> void:
	back_to_startmenu()
	
func clear_save_and_unlock_level_select() -> void:
	SettingsDataContainer.campaign_beat = true
	SaveManager.last_saved_lv.current_level = ""
	SaveManager.last_saved_lv.current_score = 0
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())

func prep_cutscene_items() -> void:
	var item_list:Array 
	item_list = get_tree().get_nodes_in_group("cutscene_items")
	print(item_list)
	for i in item_list:
		if i is ImageSpawner:
			cutscene_prop_array.append(i)
			
func reveal_prop() -> void:
	if prop_index < cutscene_prop_array.size():
		cutscene_prop_array[prop_index].visible = true
		prop_index += 1
	else:
		print("there were no props left to reveal")
		
func hide_all_props() -> void:
	for i in cutscene_prop_array:
		i.visible = false

func play_music() -> void:
	if music_player.stream != null:
		music_player.play()

func swap_tracks(audio_filepath:String) -> void:
	var filePath:String = ""
	if audio_filepath != "" and audio_filepath != null:
		filePath = audio_filepath
	else:
		filePath = default_audio_path
	var new_track = load(filePath)
	music_player.stream = new_track

func update_clear_medals() -> void:
	#Don't change if player used level select to skip levels:
	if Events.level_select_used == true:
		return
	
	#Otherwise resume function
	var current_clear_type = SettingsDataContainer.lives_type
	var current_diff = SettingsDataContainer.difficulty
	
	### Check for Endurance Lives Type: ###
	if current_clear_type == 1:
		#translate best clear to a number
		var best_clear:int
		match SaveManager.save_data.best_campaign_win_endure:
			"Easy":
				best_clear = 0
			"Normal":
				best_clear = 1
			"Hard":
				best_clear = 2
			"":
				best_clear = -1
			_:
				best_clear = -1
		if best_clear >= current_diff:
			return
		else:
			match current_diff:
				0:
					SaveManager.save_data.best_campaign_win_endure = "Easy"
				1:
					SaveManager.save_data.best_campaign_win_endure = "Normal"
				2:
					SaveManager.save_data.best_campaign_win_endure = "Hard"
				_:
					pass
	### Check for Fixed Lives Type: ###
	else:
		#translate best clear to a number
		var best_clear:int
		match SaveManager.save_data.best_campaign_win_fixed:
			"Easy":
				best_clear = 0
			"Normal":
				best_clear = 1
			"Hard":
				best_clear = 2
			"":
				best_clear = -1
			_:
				best_clear = -1
		if best_clear >= current_diff:
			return
		else:
			match current_diff:
				0:
					SaveManager.save_data.best_campaign_win_fixed = "Easy"
				1:
					SaveManager.save_data.best_campaign_win_fixed = "Normal"
				2:
					SaveManager.save_data.best_campaign_win_fixed = "Hard"
				_:
					pass
	### Save the data adjusted ###
	SaveManager.save_data.save()
