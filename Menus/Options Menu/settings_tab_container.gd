class_name SettingsTabContainer
extends Control

@onready var general_tab: TabBar = $TabContainer/General as TabBar
@onready var sound_tab: TabBar = $TabContainer/Sound as TabBar
@onready var graphics_tab: TabBar = $TabContainer/Graphics as TabBar
@onready var controls_tab: TabBar = $TabContainer/Controls as TabBar
#@onready var advanced_tab: TabBar = $"TabContainer/Accesiblity and Advanced Settings" as TabBar


@onready var tab_container: TabContainer = $TabContainer as TabContainer
@onready var input_settings: Control = $TabContainer/Controls/MarginContainer/VBoxContainer/InputSettings
@onready var viewport_tracker: Viewport = get_viewport()
#Submenu navigation variables
var submenu_value: int = 0
var inside_submenu: bool = false
var lock_tab_navigation_bool: bool = false
signal keybind_in_process
signal keybind_over
@onready var unlock_delay: Timer = %unlock_delay

signal Exit_Options_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_settings.remapping_in_progress.connect(lock_tab_navigation)
	input_settings.remapping_ended.connect(unlock_tab_navigation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tab_navigation()

func change_tab(tab: int) -> void:
	inside_submenu = false
	tab_container.set_current_tab(tab)
	print(inside_submenu)
	print(tab)
	
func tab_navigation() -> void:
	if lock_tab_navigation_bool == true:
		return
	if Input.is_action_just_pressed("ui_right"):
		if tab_container.current_tab >= tab_container.get_tab_count() - 1:
			change_tab(0)
			return
		var next_tab = tab_container.current_tab + 1
		change_tab(next_tab)
	if Input.is_action_just_pressed("ui_left") and input_settings.action_to_remap != "move_left":
		print(input_settings.action_to_remap)
		if tab_container.current_tab == 0:
			change_tab(tab_container.get_tab_count() - 1)
			return
		var prev_tab = tab_container.current_tab - 1
		change_tab(prev_tab)
		
	if Input.is_action_just_pressed("ui_cancel"):
		Exit_Options_menu.emit()

func lock_tab_navigation() -> void:
	lock_tab_navigation_bool = true
	print("tab navigation locked")
func unlock_tab_navigation() -> void:
	unlock_delay.start(.1)
func _on_unlock_delay_timeout() -> void:
	lock_tab_navigation_bool = false
	print("tab navigation unlocked")
	
func _on_focus_changed(control:Control) -> void:
	if control != null:
		print(control.name)

func is_navigation_remapping() -> bool:
	var critical_key = false
	if input_settings.action_to_remap == "move_left":
		critical_key = true
	if input_settings.action_to_remap == "move_right":
		critical_key = true
	return critical_key
