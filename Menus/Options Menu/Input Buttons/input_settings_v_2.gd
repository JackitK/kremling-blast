extends Control

@onready var input_button_scene = preload("res://Menus/Options Menu/Input Buttons/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var input_button: Button = %InputButton
@onready var reset_button: Button = %ResetButton

var is_remapping = false
var action_to_remap = null
var remapping_button = null
signal remapping_in_progress
signal remapping_ended

var input_actions = {} as Dictionary

var input_actions_key = {
	"shoot": "Shoot",
	"power_up": "Kong Power",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"move_up": "Move Up",
	"move_down": "Move Down",
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_actions = input_actions_key
	load_keybinds()
	create_action_list()

func load_keybinds() -> void:
	for action in input_actions:
		var event = SettingsDataContainer.get_keybind(action)
		
		if event != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)

func create_action_list():
	#InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
		
	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")	
		
		action_label.text = input_actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
				input_label.text = trim_controller_label(events[0].as_text())
		else:
			input_label.text = ""
			
		action_list.add_child(button)
		button.pressed.connect(on_input_button_pressed.bind(button, action))
		
		
func on_input_button_pressed(button, action):
	if !is_remapping:
		remapping_in_progress.emit()
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."
		
func _input(event):
	if is_remapping:
		if (
			event is InputEventKey || 
			event is InputEventJoypadMotion ||
			event is InputEventJoypadButton ||
			event is InputEventMouseButton
		):
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			
			if event is InputEventMouseButton || InputEventKey:
				InputMap.action_erase_events(action_to_remap)
				InputMap.action_add_event(action_to_remap, event)
				update_action_list(remapping_button, event)
				SettingsDataContainer.set_keybind(action_to_remap, event)
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			accept_event()
			remapping_ended.emit()
			
func update_action_list(button, event):
		var input_text = event.as_text()
		button.find_child("LabelInput").text = trim_controller_label(input_text)

func _on_reset_button_pressed() -> void:
	InputMap.load_from_project_settings()
	SettingsDataContainer.reset_keybinds() 
	create_action_list()
	


func _on_bind_swap_button_pressed() -> void:
		load_keybinds()
		create_action_list()

func trim_controller_label(label:String) -> String:
	var new_string = label
	new_string = new_string.trim_prefix("Joypad ")
	if new_string.contains("Mouse"):
		return new_string
	new_string = new_string.trim_suffix(" (Physical)")
	if new_string.contains("Button"):
		new_string = new_string.substr(0,9)
	elif new_string.contains("Axis"):
		new_string = new_string.trim_prefix("Motion on ")
		new_string = new_string.substr(0,6)
	return new_string
