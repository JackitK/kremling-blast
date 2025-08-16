class_name DonkeyKong
extends Kong
@onready var strong_kong_timer: Timer = $strong_kong_timer
@onready var sparkle_effect: AnimatedSprite2D = $"sparkle effect"
@onready var dk_animation_player: AnimationPlayer = %dk_animation_player

var strong_kong_time :float = 0.0
const STRONG_KONG_TIME_MAX : float = 60.0
const base_time_increase : float = 15.0
const BONUS_TIME_BONUS_MAX : int = 15
var bonus_time_bonus : int = 0
var stale_sk_hit_counter: int = 0

func _ready() -> void:
	animation_player = dk_animation_player
	super()
func kong_power():
	if strong_kong_time < base_time_increase:
		strong_kong_time = base_time_increase
	else:
		strong_kong_time = strong_kong_timer.time_left + base_time_increase
	if strong_kong_time > STRONG_KONG_TIME_MAX + base_time_increase:
		strong_kong_time = STRONG_KONG_TIME_MAX
		return
	else:
		power_up.play()
		strong_kong_timer.start(strong_kong_time)
		invulnerable = true
		sparkle_effect.visible = true
		Events.emit_banana_tally(-1)


func _on_strong_kong_timer_timeout() -> void:
	invulnerable = false
	sparkle_effect.visible = false
	if points_earned > 200:
		points_earned - 50
	else:
		points_earned = 0
	strong_kong_time = 0.0

func bad_guy_collide_event(area):
	var object = area.get_parent()
	if object is not Baddy:
		return
	if invulnerable:
		strong_kong_bonus(object)
		#Ghost Kritter specific actions:
		if object is GhostKritter:
			if object.hiding == true:
				object.got_bumped.emit()
		#--- end of ghost kritter actions
		
func strong_kong_bonus(object):
	if object is Baddy:
		var stale_power:bool = false
		if points_earned >= max_points_earned:
			stale_power = true
		if stale_power == false:
			Events.emit_enemy_hit(1)
		if object.score_value >= 2:
			if stale_power:
				Events.emit_score_tally(1)
			else:
				Events.emit_score_tally(2)
				points_earned += 2
		else:
			if stale_power == false || stale_sk_hit_counter < 2:
				Events.emit_score_tally(1)
				stale_sk_hit_counter += 1
			else:
				print("too many strong kong hits")
				stale_sk_hit_counter = 0
		power_up.play()
	
