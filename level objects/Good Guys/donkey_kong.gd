class_name DonkeyKong
extends Kong
@onready var strong_kong_timer: Timer = $strong_kong_timer
@onready var sparkle_effect: AnimatedSprite2D = $"sparkle effect"
var strong_kong_time :float = 0.0
const STRONG_KONG_TIME_MAX : float = 60.0
const base_time_increase : float = 15.0
const BONUS_TIME_BONUS_MAX : int = 15
var bonus_time_bonus : int = 0

func kong_power():
	print("Go DK!")
	if strong_kong_time < base_time_increase:
		strong_kong_time = base_time_increase
	else:
		strong_kong_time = strong_kong_timer.time_left + base_time_increase
	if strong_kong_time > STRONG_KONG_TIME_MAX + base_time_increase:
		strong_kong_time = STRONG_KONG_TIME_MAX
		print("too much time stacked, wait")
		return
	else:
		power_up.play()
		print(strong_kong_time)
		strong_kong_timer.start(strong_kong_time)
		invulnerable = true
		sparkle_effect.visible = true
		Events.emit_banana_tally(-1)


func _on_strong_kong_timer_timeout() -> void:
	invulnerable = false
	sparkle_effect.visible = false
	strong_kong_time = 0.0

func bad_guy_collide_event():
	if invulnerable:
		strong_kong_bonus()
		
		
func strong_kong_bonus():
	Events.emit_enemy_hit(1)
	power_up.play()
