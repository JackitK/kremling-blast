extends Control

@onready var state_label: Label = %State_Label
@onready var check_button: CheckButton = %CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_button.toggled.connect(on_customcursor_toggled)
	load_data()
	if SettingsDataContainer.custom_cursor == true:
		check_button.set_pressed_no_signal(true)
	elif SettingsDataContainer.custom_cursor == false:
		check_button.set_pressed_no_signal(false)
	set_label_text(check_button.button_pressed)

func load_data() -> void:
	on_customcursor_toggled(SettingsDataContainer.custom_cursor)
	
func set_label_text(button_pressed: bool) -> void:
	if button_pressed != true:
		state_label.text = "Off"
	else:
		state_label.text = "On"

func on_customcursor_toggled(button_pressed: bool) -> void:
	set_label_text(button_pressed)
	SettingsSignalBus.emit_on_custom_cursor_set(button_pressed)
	set_custom_cursor()

func set_custom_cursor() -> void:
	if SettingsDataContainer.custom_cursor:
		Input.set_custom_mouse_cursor(preload("res://sprite/crosshairs.png"), 0, Vector2(16,16))
	else:
		Input.set_custom_mouse_cursor(null)
