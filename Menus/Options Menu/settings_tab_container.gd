class_name SettingsTabContainer
extends Control

@export var mini:bool = false
@onready var general_tab: TabBar = $TabContainer/General as TabBar
@onready var sound_tab: TabBar = $TabContainer/Sound as TabBar
@onready var graphics_tab: TabBar = $TabContainer/Graphics as TabBar
@onready var tab_container: TabContainer = $TabContainer as TabContainer
@onready var window_mode_button: Control = %Window_Mode_Button
@onready var resultion_mode_button: Control = %Resultion_Mode_Button

@onready var viewport_tracker: Viewport = get_viewport()
#Submenu navigation variables
var submenu_value: int = 0
var inside_submenu: bool = false
var lock_tab_navigation_bool: bool = false
signal keybind_in_process
signal keybind_over
@onready var unlock_delay: Timer = %unlock_delay
signal Exit_Options_menu
signal make_res_butt_visible(is_visibile:bool)

@onready var confirm_prompt = preload("res://Menus/Options Menu/confirmation_container.tscn")
var confirm_message:ConfirmContainer
@onready var canvas: CanvasLayer = $CanvasLayer
@onready var sound_file = preload("res://sounds/sound effects/enivornment/boom.wav")
@onready var sound_player: AudioStreamPlayer2D = $sound_player

@onready var autofire_option: Control = $TabContainer/General/MarginContainer/ScrollContainer/VBoxContainer/Autofire_option
@onready var autofire_rate_slider: Control = $TabContainer/General/MarginContainer/ScrollContainer/VBoxContainer/autofire_rate_slider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.play_sound.connect(play_sound_effect)
	SettingsSignalBus.res_butt_reveal.connect(hide_reveal_resolution_butt)
	toggle_autofire_slider(SettingsDataContainer.autofire_state)
	SettingsSignalBus.on_autofire_toggled.connect(toggle_autofire_slider)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tab_navigation()
	check_for_input()


func change_tab(tab: int) -> void:
	inside_submenu = false
	tab_container.set_current_tab(tab)
	
func tab_navigation() -> void:
	if lock_tab_navigation_bool == true:
		return
	if Input.is_action_just_pressed("ui_right"):
		if tab_container.current_tab >= tab_container.get_tab_count() - 1:
			change_tab(0)
			return
		var next_tab = tab_container.current_tab + 1
		change_tab(next_tab)
	if Input.is_action_just_pressed("ui_left"):
		if tab_container.current_tab == 0:
			change_tab(tab_container.get_tab_count() - 1)
			return
		var prev_tab = tab_container.current_tab - 1
		change_tab(prev_tab)
		
	if Input.is_action_just_pressed("ui_cancel"):
		Exit_Options_menu.emit()

func lock_tab_navigation() -> void:
	lock_tab_navigation_bool = true
func unlock_tab_navigation() -> void:
	unlock_delay.start(.1)
func _on_unlock_delay_timeout() -> void:
	lock_tab_navigation_bool = false
	
func _on_focus_changed(control:Control) -> void:
	if control != null:
		pass

func show_confirmation_prompt(type:String) -> void:
	if not confirm_message:
		confirm_message = confirm_prompt.instantiate()
		confirm_message.confirmation_type = type
		canvas.add_child(confirm_message)
		
func _on_reset_score_button_pressed() -> void:
	show_confirmation_prompt("reset_score")
	get_tree().paused = true
	
func _on_settings_default_pressed() -> void:
	show_confirmation_prompt("default_settings")
	get_tree().paused = true

func _on_erase_all_pressed() -> void:
	show_confirmation_prompt("erase_everything")
	get_tree().paused = true

func play_sound_effect(prompt:String) ->void:
	match prompt:
		"boom":
			sound_file = load("res://sounds/sound effects/enivornment/boom.wav")
		"cheat":
			sound_file = load("res://sounds/sound effects/enivornment/flashback-2.wav")
	sound_player.stream = sound_file
	sound_player.play()

func check_for_input() -> void:
	if Input.is_action_just_pressed("k_key") and SettingsDataContainer.campaign_beat == false:
		play_sound_effect("cheat")
		SettingsDataContainer.on_set_campaign_beaten(true)

func hide_reveal_resolution_butt(is_visible) -> void:
	print("run reveal button function current value is:")
	print(is_visible)
	if is_visible and resultion_mode_button.visible == false:
		resultion_mode_button.visible = true
	elif is_visible == false and resultion_mode_button.visible:
		resultion_mode_button.visible = false


func _on_exit_pressed() -> void:
	if mini:
		SettingsSignalBus.emit_set_settings_dictionary(SettingsDataContainer.create_storage_dictionary())
		SettingsSignalBus.emit_set_levels_dictionary(LevelData.create_level_data_dictionary())
		Events.emit_live_update_settings()
		Events.emit_hide_while_in_options()
		queue_free()

func toggle_autofire_slider(value:bool) -> void:
	if value == false:
		autofire_rate_slider.visible = false
	else:
		autofire_rate_slider.visible = true
