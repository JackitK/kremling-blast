extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton as OptionButton


const WINDOWS_MODE_ARRAY : Array[String] = [
	"Window Mode",
	"Full-screen",
	"Borderless Window",
	"Borderless fullscreen"
]


func _ready():
	add_window_mode_items()
	option_button.item_selected.connect(on_window_mode_selected)
	load_data()
	
func load_data() -> void:
	on_window_mode_selected(SettingsDataContainer.get_window_mode_index())
	option_button.select(SettingsDataContainer.get_window_mode_index())

func add_window_mode_items() -> void:
	for window_mode in WINDOWS_MODE_ARRAY:
		option_button.add_item(window_mode)

func on_window_mode_selected(index : int ) -> void:
	SettingsSignalBus.emit_on_window_mode_selected(index)
	match index:
		0: #window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			
		2: #Borderless Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: #Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			
	#Send a signal back to the settings tab container to either hide or unhide resolution button:
	if index == 0 || index == 2:
		SettingsSignalBus.emit_res_butt_reveal(true)
	else:
		SettingsSignalBus.emit_res_butt_reveal(false)
