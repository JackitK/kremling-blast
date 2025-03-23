extends Control

@onready var state_label: Label = %State_Label
@onready var check_button: CheckButton = %CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_button.toggled.connect(on_subtitles_toggled)
	load_data()

func load_data() -> void:
	on_subtitles_toggled(SettingsDataContainer.subtitles_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_label_text(button_pressed: bool) -> void:
	if button_pressed != true:
		state_label.text = "Off"
	else:
		state_label.text = "On"

func on_subtitles_toggled(button_pressed: bool) -> void:
	set_label_text(button_pressed)
	SettingsSignalBus.emit_on_subtitles_toggled(button_pressed)
