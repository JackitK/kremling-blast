class_name OptionsMenu
extends Control
@onready var exit_button: Button = %Exit as Button
@onready var settings_tab_container: SettingsTabContainer = $MarginContainer/VBoxContainer/Settings_Tab_Container as SettingsTabContainer


signal exit_options_menu



func _ready() -> void:
	exit_button.button_down.connect(on_exit_options_pressed)
	settings_tab_container.Exit_Options_menu.connect(on_exit_options_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_exit_options_pressed() -> void:
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	print("Autofire state " + str(SettingsDataContainer.autofire_state))
	LevelTransition.fade_from_back()
