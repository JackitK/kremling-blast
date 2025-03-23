extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect
	

func fade_from_back():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	
func fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
