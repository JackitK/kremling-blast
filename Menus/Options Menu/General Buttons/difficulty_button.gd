extends Control
class_name Diffculty_button

@onready var option_button: OptionButton = $HBoxContainer/OptionButton
@onready var description_label: Label = $HBoxContainer/description_label

func _ready() -> void:
	load_data()
	set_description()

func load_data() -> void:
	option_button.select(SettingsDataContainer.get_difficulty())

func set_description():
	match option_button.selected:
		0:
			description_label.text = "Characters move slower and don't speed-up when hit.
			More misses allowed."
		1:
			description_label.text = "Default misses and enemy movements. Option to continue after Game Over allowed,
			but at the cost of cutting your score in half."
		2:
			description_label.text = "Faster characters. Less misses allowed. Game Over deletes your save
			and boots you back to the main menu."


func _on_option_button_item_selected(index: int) -> void:
	SettingsSignalBus.emit_on_difficulty_set(index)
	set_description()
