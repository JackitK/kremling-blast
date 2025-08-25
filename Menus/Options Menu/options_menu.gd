class_name OptionsMenu
extends Control
@onready var exit_button: Button = %Exit as Button
@onready var settings_tab_container: SettingsTabContainer = $MarginContainer/VBoxContainer/Settings_Tab_Container as SettingsTabContainer


signal exit_options_menu



func _ready() -> void:
	exit_button.button_down.connect(on_exit_options_pressed)
	settings_tab_container.Exit_Options_menu.connect(on_exit_options_pressed)
	Events.reset_room_signal.connect(reset_room)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_exit_options_pressed() -> void:
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	LevelTransition.fade_from_back()

func reset_room() -> void:
	await LevelTransition.fade_to_black()
	if settings_tab_container.sound_player.playing:
		if get_tree().paused == false:
			get_tree().paused = true
		await settings_tab_container.sound_player.finished
	
	if get_tree().paused == true:
		get_tree().paused = false
	get_tree().reload_current_scene()
	LevelTransition.fade_from_back()
	
