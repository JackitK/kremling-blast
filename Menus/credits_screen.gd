extends CenterContainer

func on_exit_level_select_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	LevelTransition.fade_from_back()
