class_name OutofBounds
extends Area2D


func _on_area_entered(area: Area2D) -> void:
	var object = area.get_parent()
	if object is Node2D:
		if "start_position" in object:
			object.global_position = object.start_position
		else:
			object.global_position = Vector2(500,500)
	elif area is Spawner:
		if "start_position" in area:
			area.global_position = area.start_position
