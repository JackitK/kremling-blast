extends Control

@onready var audio_name_lbl: Label = $HBoxContainer/Audio_Name_Lbl as Label
@onready var audio_num_lbl: Label = $HBoxContainer/Audio_Num_Lbl as Label
@onready var h_slider: HSlider = $HBoxContainer/HSlider as HSlider
@onready var test_button: Button = $HBoxContainer/test_button
@onready var test_sound: AudioStreamPlayer2D = $test_sound

@export_enum("Master", "Music", "Sfx", "Gun") var bus_name :String

var bus_index : int = 0

func _ready():
	h_slider.value_changed.connect(on_value_changed)
	get_bus_name_by_index()
	load_data()
	set_name_label_text()
	set_slider_value()
	set_up_test_button()
	
func load_data() -> void:
	match bus_name:
		"Master":
			on_value_changed(SettingsDataContainer.get_master_sound())
		"Music":
			on_value_changed(SettingsDataContainer.get_music_sound())
		"Sfx":
			on_value_changed(SettingsDataContainer.get_sfx_sound())
		"Gun":
			on_value_changed(SettingsDataContainer.get_gun_sound())

func set_name_label_text() -> void:
	audio_name_lbl.text = str(bus_name) + " Volume"
	
func set_audio_num_label_text() -> void:
	audio_num_lbl.text = str(h_slider.value * 100)

func get_bus_name_by_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	

func set_slider_value() -> void:
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()
	
	
func on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()
	
	match bus_index:
		0:
			SettingsSignalBus.emit_on_master_sound_set(value)
		1:
			SettingsSignalBus.emit_on_music_sound_set(value)
		2:
			SettingsSignalBus.emit_on_sfx_sound_set(value)
		3:
			SettingsSignalBus.emit_on_gun_sound_set(value)

func set_up_test_button() -> void:
	match bus_name:
		"Master", "Music":
			test_button.visible = false
		"Sfx":
			test_sound.stream = load("res://sounds/sound effects/Baddies/KritterHurt_1.wav")
			test_button.icon = load("res://sprite/Baddies/Kritter.png")
		"Gun":
			test_sound.stream = load("res://sounds/sound effects/coconut_gun_2.wav")
			test_sound.bus = "Gun"
			test_button.icon = load("res://sprite/crosshairs.png")
	if test_button.visible == true:	
		test_button.pressed.connect(test_button_pressed)
			
func test_button_pressed() -> void:
	test_sound.play()
