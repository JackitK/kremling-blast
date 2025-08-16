extends Control

@onready var state_label: Label = %State_Label
@onready var check_button: CheckButton = %CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_button.toggled.connect(on_customcursor_toggled)
	load_data()
	if SettingsDataContainer.mobile_buttons == true:
		check_button.set_pressed_no_signal(true)
	elif SettingsDataContainer.mobile_buttons == false:
		check_button.set_pressed_no_signal(false)
	set_label_text(check_button.button_pressed)

func load_data() -> void:
	on_customcursor_toggled(SettingsDataContainer.mobile_buttons)
	
func set_label_text(button_pressed: bool) -> void:
	if button_pressed != true:
		state_label.text = "Off"
	else:
		state_label.text = "On"

func on_customcursor_toggled(button_pressed: bool) -> void:
	set_label_text(button_pressed)
	SettingsSignalBus.emit_on_mobile_buttons_set(button_pressed)
