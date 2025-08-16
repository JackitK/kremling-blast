extends Bonus_Level
class_name One_off_Level


	
func track_highscore() -> void:
	print("tracking Highscore for endless mode")
	var play_session_score: int = Events.total_score
	var best_score = SaveManager.save_data.endless_score
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
		SaveManager.save_data.endless_score = play_session_score
		SaveManager.save_data.diff_endless = mode
		SaveManager.save_data.save()

func bonus_stage_intro():
	pause_menu.set_process(false)
	score_display.visible = false
	banana_counter.visible = false
	time_label.visible = false
	level_time_label.visible = false
	bonus_message_container.visible = true
	intro_timer.start()
	get_tree().paused = true

func _on_victory_theme_finished() -> void:
	get_tree().paused = false
	go_to_next_level()

func go_to_next_level():
	Events.total_score = score
	print("score " + str(Events.total_score))
	if next_level is PackedScene:
		get_tree().change_scene_to_packed(next_level)
	else:
		back_to_startmenu()
