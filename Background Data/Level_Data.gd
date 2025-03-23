class_name Cookie
extends Node
# Implment later to store the best records of each level. Ideally achieved with signals so I don't have to have mutiple global var for each level
#Includes data such as best cookie count, best time (any cookies), and best time (all cookies)


# Tied to starting level, and data relating to writing and reading level data

var loaded_data : Dictionary = {}

# Possibly convert certain global "event" variables (such as total cookie count) into data stored here and updated with signals as well
var level_cookie_list
@onready var starting_position: Vector2
@onready var cookie_list: Array

# Dictonary that stores each level:
const LEVEL_DICTIONARY : Dictionary = {
	# 320 x 180 is old default resolution, attempting to change default resolution to 1152 x 648
	"Level 1": preload("res://levels/level1.tscn") as PackedScene,
	"Level 2": preload("res://levels/level2.tscn")
}
var start_level_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	handle_signals()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func collectables_post_checkpoint ():
	pass

func create_level_data_dictionary() -> Dictionary:
	var level_container_dict : Dictionary = {
		"start_level_index": start_level_index as int
		}
	return level_container_dict
	
func on_start_level_selected(index : int) -> void:
	start_level_index = index
	
func get_start_level() -> int:
	if loaded_data == {}:
		return 0
	return start_level_index
	
	
func handle_signals() -> void:
	SettingsSignalBus.load_levels_data.connect(on_level_data_loaded)
	
func on_level_data_loaded(data: Dictionary) -> void:
	loaded_data = data
	on_start_level_selected(loaded_data.start_level_index)
	
func load_level_from_index() -> PackedScene:
	var level : PackedScene = preload("res://levels/level1.tscn") as PackedScene
	if LEVEL_DICTIONARY.values()[start_level_index] is PackedScene:
		level = LEVEL_DICTIONARY.values()[start_level_index]
	return level
