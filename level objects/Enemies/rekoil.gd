class_name Rekoil
extends Baddy
#@onready var sprite: AnimatedSprite2D = %Rekoil_sprite

@export var ground_time:float = 3.0
@export var air_time:float = 1.0

@onready var bounce_timer: Timer = %bounce_timer
@onready var spring_sound: AudioStreamPlayer2D = %spring_sound
@onready var shadow_dector: Area2D = $shadow_dector

var is_in_air:bool = false

func _ready() -> void:
	bounce_timer.start(ground_time)
	super()
	
func set_sprite_to_child_sprite() -> void:
	sprite = %Rekoil_sprite
	
func rekoil_jump() -> void:
	spring_sound.play()
	hide_shoot_colision()
	hide_interaction_with_objects()
	bounce_timer.start(air_time)
	sprite.animation = "bouncing"
	is_in_air = true
	shadow_dector.visible = true
	
	
func rekoil_grounded() -> void:
	reveal_shoot_colision()
	reveal_interaction_with_objects()
	bounce_timer.start(ground_time)
	sprite.animation = "default"
	is_in_air = false
	shadow_dector.visible = false

#When the timer runs out, either make the object "jump" or "return to the ground"
func _on_bounce_timer_timeout() -> void:
	if is_in_air == false:
		rekoil_jump()
	else:
		rekoil_grounded()

func _on_sprite_animation_changed() -> void:
	if sprite.animation == "bouncing":
		is_in_air = true
		set_collision_layer_value(1, false)
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
		set_collision_mask_value(2, false)
		nearby_dector.set_collision_mask_value(2, false)
		nearby_dector.set_collision_mask_value(1, false)
		shadow_dector.set_collision_layer_value(6, true)
	else:
		is_in_air = false
		set_collision_layer_value(1, true)
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(2, true)
		nearby_dector.set_collision_mask_value(2, true)
		nearby_dector.set_collision_mask_value(1, true)
		shadow_dector.set_collision_layer_value(6, false)


func _on_shadow_dector_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if area.is_in_group("breakable_block") :
		if is_in_air:
			bounce_timer.paused = true
			var new_time = bounce_timer.time_left +.01
			bounce_timer.start(new_time)
	if obj is DiddyKong:
		if obj.jetpack_activate and is_in_air:
			hit_by_flying_obj()
			if obj.jetpack_blaze:
				obj.jetpack_bonus()

func _on_nearby_dector_area_exited(area: Area2D) -> void:
	if area.is_in_group("breakable_block") and bounce_timer.paused == true:
		bounce_timer.paused = false

func hit_by_flying_obj() -> void:
	baddy_sound.play()
	bounce_timer.stop()
	Events.emit_score_tally(score_value + 1)
	Events.emit_enemy_hit(shot_value + 1)
	_on_bounce_timer_timeout()

func check_if_in_shoot_zone(state:bool) -> void:
	if is_in_air:
		return
	else:
		super(state)
