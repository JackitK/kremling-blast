extends TextureButton
class_name KongButton
@onready var banana_disclaimer: Label = $banana_disclaimer
@onready var display_timer: Timer = $display_timer

signal disclaim_signal

func _ready() -> void:
	disclaim_signal.connect(run_disclaimer)

func run_disclaimer() -> void:
	banana_disclaimer.visible = true
	display_timer.start()

func _on_display_timer_timeout() -> void:
	banana_disclaimer.visible = false


func _on_pressed() -> void:
	Events.emit_kong_button_prompt()
