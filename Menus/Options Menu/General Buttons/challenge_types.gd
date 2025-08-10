extends Control
class_name Challenge_type

@onready var option_button: OptionButton = $HBoxContainer/OptionButton
@onready var description_label: Label = $HBoxContainer/description_label

func _ready() -> void:
	load_data()
	set_description()

func load_data() -> void:
	option_button.select(SettingsDataContainer.get_lives_type())
func set_description():
	
	match option_button.selected:
		0:
			description_label.text = "Miss Count before Game Over is set each level."
		1:
			description_label.text = "Start out with a larger amount of misses before game-over,
			but misses don't reset between levels."


func _on_option_button_item_selected(index: int) -> void:
	SettingsSignalBus.emit_on_lives_type_set(index)
	set_description()
