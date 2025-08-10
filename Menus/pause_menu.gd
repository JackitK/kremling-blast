extends Control
@onready var resume_button: Button = $PanelContainer/VBoxContainer/Resume
@onready var quit_button: Button = $PanelContainer/VBoxContainer/Quit

@onready var mini_options_template = preload("res://Menus/Options Menu/mini_options.tscn")
var mini_options:SettingsTabContainer
@onready var settings_canvas: CanvasLayer = $CanvasLayer

#Signals to send data from the level to the pause menu
#signal loadCompeltionData(int cookie_count_current, cookie_count_level)
signal test()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("RESET")
	resume_button.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pausePress_test()
	
func resume():
	if visible == true:
		visible = false
		get_tree().paused = false
		$AnimationPlayer.play_backwards("blur")
	
func pause():
	if visible == false:
		visible = true
		resume_button.grab_focus()
		get_tree().paused = true
		$AnimationPlayer.play("blur")
	
func pausePress_test():
	#var pause_input:bool
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
func _on_resume_pressed() -> void:
	resume()

func _on_options_pressed() -> void:
	if not mini_options:
		mini_options = mini_options_template.instantiate()
		mini_options.mini = true
		settings_canvas.add_child(mini_options)

#Returns to main menu, instead of quitting the game.
func _on_quit_pressed() -> void:
	if visible == true:
		print("back to sm button pressed")
		resume()
		Events.emit_back_to_start_menu()
