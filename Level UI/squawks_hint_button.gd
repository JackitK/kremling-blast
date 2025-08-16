extends TextureButton
@onready var hint_label: Label = %hint_label
@onready var click_prompt_label: Label = %click_prompt_label
@onready var squawk_sound: AudioStreamPlayer2D = $squawk_sound


@export var export_file_path: String = ""
@export var hint_available: bool = true
var loaded_hint: String = "Hint go here!"
var paused_for_hint:bool = false

func _ready() -> void:
	load_and_store_dialouge_from_file()
	hint_label.text = loaded_hint
	if hint_available == false:
		visible = false
	else:
		Events.hide_while_in_options.connect(hide_while_in_options)

func load_and_store_dialouge_from_file():
	var filePath = ""
	if export_file_path != "" and export_file_path != null:
		filePath = export_file_path
	else:
		loaded_hint = "Sorry! No hint loaded"
		hint_available = false
		return
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	#Possibly added character limit check later...
	loaded_hint = content
	file.close()


func _on_mouse_entered() -> void:
	hint_label.visible = true
	click_prompt_label.visible = false


func _on_mouse_exited() -> void:
	if paused_for_hint == true:
		get_tree().paused = false
		hint_label.visible = false
		click_prompt_label.visible = true
		paused_for_hint = false
	else:
		hint_label.visible = false
		click_prompt_label.visible = true


func _on_pressed() -> void:
	if get_tree().paused == false:
		squawk_sound.play()
		hint_label.visible = true
		click_prompt_label.visible = false
		paused_for_hint = true
		get_tree().paused = true

func hide_while_in_options() -> void:
	if visible:
		visible = false
	else:
		visible = true
