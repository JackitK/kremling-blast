class_name DiddyKong
extends Kong

var jetpack_time :float = 15.0
var temp_speed_storage: float = 200.0
var jetpack_activate : bool = false
var jetpack_blaze : bool = false
var jetpack_hit_counter : int = 0

@onready var jetpack_timer: Timer = $jetpack_timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var blaze_animation: AnimatedSprite2D = $nearby_detector/blaze
@onready var blaze_sound: AudioStreamPlayer2D = $sound_effects/blaze


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
		sprite.texture = load("res://sprite/Kongs/Diddy Kong_jetpack.png")
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
	jetpack_time = 0.0
	jetpack_activate = false
	jetpack_blaze = false
	blaze_animation.visible = false
	speed = temp_speed_storage
	sprite.texture = load("res://sprite/Kongs/Diddy Kong.png")

func bad_guy_collide_event(area):
	if jetpack_activate:
		jetpack_bonus()
func good_guy_collide_event(area):
	if jetpack_blaze:
		friendly_fire(area)
		
func jetpack_bonus():
	if jetpack_blaze:
		Events.emit_enemy_hit(2)
		Events.emit_score_tally(1)
	else:
		jetpack_hit_counter += 1
		if jetpack_hit_counter >= 2:
			jetpack_hit_counter = 0
			Events.emit_enemy_hit(1)
			Events.emit_score_tally(1)
		else:
			Events.emit_enemy_hit(1)
	power_up.play()
	
func friendly_fire(area):
	var object = area.get_parent()
	if object is Kong:
		object.panic_event()

func _on_nearby_detector_area_entered(area: Area2D) -> void:
	super(area)

func panic_event() -> void:
	if jetpack_blaze:
		pass
	else:
		super()
