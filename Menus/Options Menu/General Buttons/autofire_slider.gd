extends Control

@onready var audio_name_lbl: Label = $HBoxContainer/Audio_Name_Lbl as Label
@onready var audio_num_lbl: Label = $HBoxContainer/Audio_Num_Lbl as Label
@onready var h_slider: HSlider = $HBoxContainer/HSlider as HSlider


func _ready():
	h_slider.value_changed.connect(on_value_changed)
	load_data()
	set_slider_value()
	
func load_data() -> void:
	h_slider.value = SettingsDataContainer.autofire_rate

	
func update_slider_text() -> void:
	audio_num_lbl.text = "Shoot every " + str(h_slider.value) + " seconds"

	

func set_slider_value() -> void:
	h_slider.value = SettingsDataContainer.autofire_rate
	update_slider_text()
	
	
func on_value_changed(value: float) -> void:
	SettingsDataContainer.autofire_rate = value
	update_slider_text()
