class_name TinyKong
extends Kong

@onready var shrink_timer: Timer = %shrink_timer
@export var base_power_time: float = 5.0
@onready var tiny_animation_player: AnimationPlayer = %tiny_AnimationPlayer


func _ready() -> void:
	animation_player = tiny_animation_player
	super()

func kong_power():
	if shrunk_state == false:
		shrunk_state = true
		var temp_pos = position
		scale *= .5
		position = temp_pos
		shrink_the_monkeys()
		shrink_timer.start(base_power_time)
		Events.emit_banana_tally(-1)
	else:
		var timeleft = shrink_timer.time_left
		timeleft += base_power_time
		shrink_timer.start(timeleft)
		Events.emit_banana_tally(-1)


func _on_shrink_timer_timeout() -> void:
	shrunk_state = false
	var temp_pos = position
	scale = base_scale
	position = temp_pos
	grow_the_monkeys()

# Shrinks ally Kongs:
func shrink_the_monkeys() -> void:
	power_up.play()
	for member in get_tree().get_nodes_in_group("good_guys"):
		#skip the check for any non Kong objects or Chunky objects already in big mode.
		if member is not Kong:
			continue
		elif member is ChunkyKong:
			if member.big_Chunky == true:
				continue
		member.scale *= .5
		member.shrunk_state = true
		
# Grows ally Kongs back to normal size
func grow_the_monkeys() -> void:
	for member in get_tree().get_nodes_in_group("good_guys"):
		#skip the check for any non Kong objects or Chunky objects already in big mode.
		if member is not Kong:
			continue
		elif member is ChunkyKong:
			if member.big_Chunky == true:
				continue
		member.scale = member.base_scale
		member.shrunk_state = false
