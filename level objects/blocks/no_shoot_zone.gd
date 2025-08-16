extends Area2D
class_name No_Shoot_Zone

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj is Baddy || obj is Kong:
		print("object entered no shoot zone")
		obj.in_no_shoot_zone.emit(true)


func _on_area_exited(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj is Baddy || obj is Kong:
		print("object left no shoot zone")
		obj.in_no_shoot_zone.emit(false)
