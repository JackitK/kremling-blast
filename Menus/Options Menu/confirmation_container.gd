class_name ConfirmContainer
extends Control

@export_enum("reset_score", "default_settings", "erase_everything", "continue_game") var confirmation_type: String = "reset_score"
@onready var extra_details: Label = %extra_details
@onready var question_label: Label = %Question_label
@onready var answered_confirmed:String = "no_answer"

signal action_done

func _ready() -> void:
	action_done.connect(remove_message)
	adjust_confirmation_message()

func _on_button_yes_pressed() -> void:
	answered_confirmed = "yes"
	match confirmation_type:
		"reset_score":
			reset_score()
		"default_settings":
			set_settings_to_default()
		"erase_everything":
			erase_all()
		"continue_game":
			Events.will_you_continue.emit(true)

func _on_button_no_pressed() -> void:
	answered_confirmed = "no"
	if confirmation_type == "continue_game":
		Events.will_you_continue.emit(false)
	emit_signal("action_done")
	
func reset_score() -> void:
	Events.emit_play_sound("boom")
	SaveManager.save_data.high_score = 0
	SaveManager.save_data.endless_score = 0
	SaveManager.save_data.save()
	emit_signal("action_done")
	
func remove_message() ->void:
	if confirmation_type != "continue_game":
		get_tree().paused = false
	if answered_confirmed == "yes":
		if confirmation_type == "reset_score":
			pass
		elif confirmation_type == "default_settings" or "erase_everything":
			Events.reset_room_signal.emit()
	call_deferred("free")
	
func set_settings_to_default() -> void:
	print("resetting settings")
	Events.emit_play_sound("boom")
	SettingsDataContainer.default_settings_reset()
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
	emit_signal("action_done")

func erase_all() -> void:
	Events.emit_play_sound("boom")
	SaveManager.save_data.high_score = 0
	SaveManager.save_data.endless_score = 0
	SaveManager.save_data.best_campaign_win_fixed = ""
	SaveManager.save_data.best_campaign_win_endure = ""
	SaveManager.save_data.save()
	SaveManager.last_saved_lv.current_level = ""
	SaveManager.last_saved_lv.current_score = 0
	SaveManager.last_saved_lv.save()
	SettingsDataContainer.default_settings_reset()
	SettingsDataContainer.on_set_campaign_beaten(false)
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
	emit_signal("action_done")

func unlock_level_select() -> void:
	pass

func adjust_confirmation_message() -> void:
	match confirmation_type:
		"reset_score":
			extra_details.text = "This will permanently erase high scores \n in all game types..."
		"default_settings":
			extra_details.text = "All options selections will reverted \n to their default settings..."
		"erase_everything":
			extra_details.text = "This will permanently erase everything \n including save data & completion bonuses..."
		"continue_game":
			question_label.text = "Continue?"
			extra_details.text = "Retry this level, at the cost of half your score."
		"welcome":
			extra_details.text = "The game has been adjusted for mobile play. \nKeep mobile buttons on for the best experience."
