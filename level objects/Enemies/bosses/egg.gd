class_name Egg
extends Baddy
var fling_state:bool = false
var crash_state:bool = false
@onready var fling_timer: Timer = %fling_timer
@onready var despawn_timer: Timer = %despawn_timer
@onready var crash_dector: Area2D = $crash_dector
@onready var crash_timer: Timer = %crash_timer

func _ready() -> void:
	egged_event.connect(egg_crash_out)
	super()

# Update to "fling in air" when clicked and splat when falling back down after a certain time
func shot_event():
	print("egg shot")
	if sprite.animation == "default":
		sprite.animation = "in_air"
		fling_state = true
		fling_timer.start()

func _on_nearby_dector_area_entered(area: Area2D) -> void:
	if sprite.animation != "splat":
		var obj = area.get_parent()
		if obj.is_in_group("baddies"):
			if obj is Egg:
				print("delete egg")
				obj.queue_free()
			else:
				obj.egged_event.emit(self)
		if obj.is_in_group("good_guys"):
			pass

func _on_crash_dector_area_entered(area: Area2D) -> void:
	print("crash detected")
	var obj = area.get_parent()
	if obj is Kong:
		obj.egged_event.emit(self)


func _on_fling_timer_timeout() -> void:
	print("fling timer ends")
	if sprite.animation == "in_air":
		crash_state = true
		crash_dector.monitoring = true
		sprite.animation = "splat"
		

func _on_sprite_animation_changed() -> void:
	if sprite.animation == "splat":
		fling_state = false
		crash_timer.start()
		despawn_timer.start()
		nearby_dector.set_collision_mask_value(2, false)
		z_index = -1
		
	elif sprite.animation == "in_air":
		nearby_dector.set_collision_mask_value(2, true)
		set_collision_layer_value(3, false)
		

func _on_despawn_timer_timeout() -> void:
	queue_free()

func enemy_movement():
	pass


func _on_crash_timer_timeout() -> void:
	if crash_dector.monitoring == true:
		crash_dector.monitoring = false
		print("crash monitor off")

func egg_crash_out(egg:Egg) -> void:
	print("eggs splat each other")
	queue_free()

func check_if_in_shoot_zone(state:bool) -> void:
	pass
