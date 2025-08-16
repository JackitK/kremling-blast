class_name DiddyKong
extends Kong

var jetpack_time :float = 15.0
var temp_speed_storage: float = 200.0
var jetpack_activate : bool = false
var jetpack_blaze : bool = false
var jetpack_hit_counter : int = 0

@onready var jetpack_timer: Timer = $jetpack_timer
@onready var sprite: AnimatedSprite2D = $Diddy_sprite

@onready var blaze_animation: AnimatedSprite2D = %blaze_sprite
@onready var blaze_sound: AudioStreamPlayer2D = $sound_effects/blaze
@onready var diddy_animation_player: AnimationPlayer = %diddy_animation_player

func _ready() -> void:
	animation_player = diddy_animation_player
	super()

func kong_power():
	if jetpack_activate and jetpack_blaze == false:
		jetpack_blaze = true
		blaze_animation.visible = true
		speed = temp_speed_storage * 2.5
		blaze_sound.play()
		jetpack_timer.start(jetpack_time)
		Events.emit_banana_tally(-1)
	elif jetpack_activate and jetpack_blaze:
		pass
	else:
		power_up.play()
		temp_speed_storage = speed
		speed *= 1.5
		if speed > max_speed:
			speed = max_speed
		sprite.animation = "jetpack"
		jetpack_activate = true
		jetpack_timer.start(jetpack_time)
		Events.emit_banana_tally(-1)

func _on_change_direction_timer_timeout() -> void:
	if jetpack_activate:
		var new_time = randi_range(1,3)
		change_direction_timer.start(new_time)
		randomly_change_direction()
	else:
		super()

func _on_jetpack_timer_timeout() -> void:
	if points_earned > 200:
		points_earned - 50
	else:
		points_earned = 0
	jetpack_time = 0.0
	jetpack_activate = false
	jetpack_blaze = false
	blaze_animation.visible = false
	speed = temp_speed_storage
	sprite.animation = "default"

func bad_guy_collide_event(area):
	var obj = area.get_parent()
	if obj is Rekoil:
		if obj.is_in_air:
			jetpack_bonus()
			obj.hit_by_flying_obj()
	if jetpack_activate:
		jetpack_bonus()
func good_guy_collide_event(area):
	if jetpack_blaze:
		friendly_fire(area)
		

func jetpack_bonus():
	if points_earned >= max_points_earned:
		#points_earned /= 2
		#global_position = start_position
		return
	if jetpack_blaze:
		Events.emit_enemy_hit(2)
		Events.emit_score_tally(3)
		points_earned += 3
	else:
		jetpack_hit_counter += 1
		if jetpack_hit_counter >= 2:
			jetpack_hit_counter = 0
			Events.emit_enemy_hit(1)
			Events.emit_score_tally(2)
			points_earned += 2
		else:
			Events.emit_enemy_hit(1)
			Events.emit_score_tally(1)
			points_earned += 1
	power_up.play()
	
func friendly_fire(area):
	var object = area.get_parent()
	if object is Kong:
		object.panic_event()

func _on_nearby_detector_area_entered(area: Area2D) -> void:
	var obj = area.get_parent()
	if obj.is_in_group("baddies"):
		bad_guy_collide_event(area)
	if obj.is_in_group("good_guys"):
		good_guy_collide_event(area)
	if area.is_in_group("breakable_block"):
		var block = area.get_parent()
		if block is BreakableBlock:
			if jetpack_blaze == true and block.wall_type == "wood":

				burn_wood(block)
			else:
				block.collide_event.emit(weight)

func burn_wood(target) -> void:
	if target is BreakableBlock:
		blaze_sound.play()
		target.destroy_self.emit()

func panic_event() -> void:
	if jetpack_blaze:
		pass
	else:
		super()

func trigger_hurt_animation() -> void:
	if sprite.animation == "jetpack":
		animation_player.play("hit_flying")
	else:
		animation_player.play("hit")
