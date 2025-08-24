extends Cutscene

@onready var congrats_label: Label = $congrats_label

func _ready() -> void:
	check_for_extra_congrats()
	super()
	
	
func check_for_extra_congrats():
	if SettingsDataContainer.difficulty >= 2:
		congrats_label.add_theme_font_size_override("font_size", 100)
		if SettingsDataContainer.lives_type == 1:
			congrats_label.text = "Hard & Endurance Mode? \n Wow! What a Blast! \nYou're a Super Player!"
		else:
			congrats_label.text = "Wow! That was hard! \n Congrats!"
