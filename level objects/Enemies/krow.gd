extends Baddy
class_name Krow
@onready var krow_sprite: AnimatedSprite2D = %krow_sprite
@onready var fly_timer: Timer = %fly_timer
@export var ground_time:float = 2.5
@export var air_time:float = 2.0
var is_in_air:bool = false
@onready var shadow_dector: Area2D = $shadow_dector

func set_sprite_to_child_sprite() -> void:
	sprite = krow_sprite

func _ready() -> void:
	fly_timer.start(ground_time)
	egged_event.connect(get_egged)
	super()

	
func krow_fly() -> void:
	hide_shoot_colision()
	hide_interaction_with_objects()
	fly_timer.start(air_time)
	sprite.animation = "in_air"
	
	
	
func krow_grounded() -> void:
	reveal_shoot_colision()
	reveal_interaction_with_objects()
	fly_timer.start(ground_time)
	sprite.animation = "default"
	is_in_air = false

#When the timer runs out, either make the object "jump" or "return to the ground"
func _on_fly_timer_timeout() -> void:
	if is_in_air == false:
		krow_fly()
	else:
		krow_grounded()

func _on_krow_sprite_animation_changed() -> void:
	if sprite.animation == "in_air":
		is_in_air = true
		shadow_dector.set_collision_layer_value(6, true)
		#set_collision_layer_value(1, false)
		#set_collision_layer_value(2, false)
		#set_collision_layer_value(3, true)
		#set_collision_mask_value(2, false)
		shadow_dector.set_collision_layer_value(6, true)
	else:
		is_in_air = false
		#set_collision_layer_value(1, true)
		#set_collision_layer_value(2, true)
		#set_collision_layer_value(3, false)
		#set_collision_mask_value(2, true)
		shadow_dector.set_collision_layer_value(6, false)

func _on_nearby_dector_area_entered(area: Area2D) -> void:
	var first_obj = area.get_parent()
	if first_obj is DiddyKong:
		if first_obj.jetpack_activate:
			hit_by_flying_obj()
		super(area)

func _on_shadow_dector_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if area.is_in_group("breakable_block") :
		if is_in_air:
			fly_timer.paused = true
			var new_time = fly_timer.time_left +.01
			fly_timer.start(new_time)
	if obj is DiddyKong:
		if obj.jetpack_activate:
			hit_by_flying_obj()
			if obj.jetpack_blaze:
				obj.jetpack_bonus()

func _on_nearby_dector_area_exited(area: Area2D) -> void:
	if area.is_in_group("breakable_block") and fly_timer.paused == true:
		fly_timer.paused = false
		print(fly_timer.paused)
		
func hit_by_flying_obj() -> void:
	baddy_sound.play()
	if shot_value != 0:
		Events.emit_score_tally(score_value + 1)
		Events.emit_enemy_hit(shot_value + 1)
	if is_in_air:
		fly_timer.stop()
		_on_fly_timer_timeout()
		
func get_egged(egg:Egg) -> void:
	if is_in_air and egg.fling_state == true:
		if shot_value != 0:
			Events.emit_score_tally(egg.score_value)
		hit_by_flying_obj()
		egg.sprite.animation = "splat"
		animation_player.play("egged")
