extends Control
@onready var donkey: TextureButton = %Donkey
@onready var diddy: TextureButton = %Diddy
@onready var lanky: TextureButton = %Lanky
@onready var tiny: TextureButton = %Tiny
@onready var chunky: TextureButton = %Chunky


func _on_donkey_pressed() -> void:
	Events.emit_confirm_kong_selection("DonkeyKong")
	unpause_and_delete()

func _on_diddy_pressed() -> void:
	Events.emit_confirm_kong_selection("DiddyKong")
	unpause_and_delete()

func _on_lanky_pressed() -> void:
	Events.emit_confirm_kong_selection("LankyKong")
	unpause_and_delete()

func unpause_and_delete() -> void:
	if get_tree().paused:
		get_tree().paused = false
	queue_free()


func _on_tiny_pressed() -> void:
	Events.emit_confirm_kong_selection("TinyKong")
	unpause_and_delete()


func _on_chunky_pressed() -> void:
	Events.emit_confirm_kong_selection("ChunkyKong")
	unpause_and_delete()


func _on_cancel_button_pressed() -> void:
	unpause_and_delete()
