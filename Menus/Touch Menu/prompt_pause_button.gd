extends TextureButton

func _on_pressed() -> void:
	Events.pause_prompt.emit()
