extends CenterContainer

const level_folder_path: = "res://levels/campagin_levels/"
@onready var levels_container: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer
@onready var bonus_level_count: int = 0

signal exit_level_select

func _ready() -> void:
	fill_levels()
	exit_level_select.connect(on_exit_level_select_pressed)
	if levels_container.get_child_count() > 0:
		levels_container.get_child(0).grab_focus()

func fill_levels() -> void:
	var level_paths = DirAccess.get_files_at(level_folder_path)
	print(level_paths)
	for level_path in level_paths:
		var button = Button.new()
		button.text = "Level " + level_path.replace(".tscn", "").lstrip("0").rstrip(".remap.tscn")
		button.text = update_custom_level_names(button.text)
		levels_container.add_child(button)
		# To fix browser exclusive issue.
		var new_file_path = level_folder_path + level_path
		if level_path.contains(".remap"):
			print("Prestrip " + new_file_path)
			print("Remove web exclusive extensions")
			new_file_path = new_file_path.rstrip(".remap")
			#.remap seems to keep coming back, no matter how I attempt to remove it.
		print(new_file_path)
		
		button.pressed.connect(func():
			get_tree().change_scene_to_file(new_file_path)
		)

func update_custom_level_names(old_name:String) -> String:
	var new_name:String = old_name
	# Update boss fight 1 to Very Gnawty (currently saved as 10.tsn/aka Level 10
	match new_name:
		"Level 10":
			new_name = "VS Very Gnawty"
		"Level 20":
			new_name = "VS Captain Krow"
	if new_name.contains("_b"):
		bonus_level_count += 1
		new_name = "Bonus " + str(bonus_level_count)
		pass
	return new_name


func on_exit_level_select_pressed() -> void:
	SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
	SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://Menus/start_menu.tscn")
	LevelTransition.fade_from_back()
