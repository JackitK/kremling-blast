extends Baddy

@onready var klump_sprite: AnimatedSprite2D = $"Klump Sprite"

func set_sprite_to_child_sprite() -> void:
	sprite = klump_sprite
