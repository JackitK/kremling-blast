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
	handle_challenge_modifiers()

func handle_challenge_modifiers()-> void:
	var diff:int = SettingsDataContainer.get_difficulty()
	var lives:int = SettingsDataContainer.get_lives_type()
	
	# Update starting game data based on difficulty selected
	# Some features will have to be applied directly to the functions and can't be set here
	match diff:
		0: #Easy
			Events.global_lives = 30
		1: #Normal
			Events.global_lives = 20
		2: #Hard
			Events.global_lives = 5
			
	match lives:
		0: #Fixed per level
			pass
		1: #Endurance (Lives carry over between levels)
			pass
