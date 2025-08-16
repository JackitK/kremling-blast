class_name LankyKong
extends Kong

var zoom_time :float = 15.0
var temp_speed_storage: float = 200.0
var zoom_active: bool = false
@onready var zoom_timer: Timer = $timers/zoom_timer
@onready var sprite: AnimatedSprite2D = %Lanky_sprite
@onready var lanky_animation_player: AnimationPlayer = %lanky_AnimationPlayer


func _ready() -> void:
	animation_player = lanky_animation_player
	super()

func kong_power():
	if zoom_active == false:
		if sprite.animation != "handstand":
			sprite.animation = "handstand"
		zoom_active = true
		temp_speed_storage = speed
		if speed < max_speed:
			speed = speed * 3
		else:
			speed = speed * 1.5
		zoom_timer.start(zoom_time)
		power_up.play()
		Events.emit_banana_tally(-1)
	else:
		if speed < max_speed:
			speed = speed * 2
			Events.emit_banana_tally(-1)
			Events.emit_score_tally(5)
			zoom_timer.start(zoom_time)
			power_up.play()
		else:
			if SettingsDataContainer.simplify_kong_rate == false:
				Events.emit_score_tally(20)
				Events.emit_banana_tally(-1)
				zoom_timer.start(zoom_time)
				power_up.play()

func bad_guy_collide_event(area):
	if zoom_active:
		var object = area.get_parent()
		if object is Baddy:
			object.stunned_event()
			if object.stunned == true:
				Events.emit_score_tally(1)
		
		power_up.play()
	else:
		super(area)
func good_guy_collide_event(area):
	if zoom_active:
		if points_earned >= max_points_earned:
			points_earned /= 2
			global_position = start_position
			return
		Events.emit_score_tally(2)
		points_earned += 2
		power_up.play()

func _on_change_direction_timer_timeout() -> void:
	if zoom_active:
		var new_time = randi_range(1,3)
		change_direction_timer.start(new_time)
		randomly_change_direction()
	else:
		super()

func _on_zoom_timer_timeout() -> void:
	if sprite.animation == "handstand":
			sprite.animation = "default"
	if points_earned > 200:
		points_earned - 50
	else:
		points_earned = 0
	speed = temp_speed_storage
	zoom_active = false


func trigger_hurt_animation() -> void:
	if sprite.animation == "handstand":
		animation_player.play("hit_handstand")
	else:
		animation_player.play("hit")
