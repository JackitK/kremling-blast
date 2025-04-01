extends Control



@onready var option_button: OptionButton = $HBoxContainer/OptionButton as OptionButton



func _ready():
	option_button.item_selected.connect(on_level_selected)
	add_level_items()
	load_data()
	
func load_data() -> void:
	on_level_selected(LevelData.start_level_index)
	option_button.select(LevelData.start_level_index)
	
func add_level_items() -> void:
	for level_size_text in LevelData.LEVEL_DICTIONARY:
		option_button.add_item(level_size_text)
	
func on_level_selected(index: int) -> void:
	LevelData.start_level_index = index
