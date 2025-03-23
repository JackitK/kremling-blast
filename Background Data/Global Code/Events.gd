extends Node
signal enemy_hit(value : int)
signal ally_hit(value : int)
signal game_over
signal level_cleared
signal banana_tally(value : int)
signal power_up
signal shot_triggered

var enable_banana_movement: bool = true
var total_score: int = 0

func emit_enemy_hit(value: int) -> void:
	enemy_hit.emit(value)

func emit_ally_hit(value: int) -> void:
	ally_hit.emit(value)
	
func emit_game_over() -> void:
	game_over.emit()
	
func emit_level_cleared() -> void:
	level_cleared.emit()

func emit_banana_tally(value: int) -> void:
	banana_tally.emit(value)
	
func emit_power_up() -> void:
	power_up.emit()

# in game functions
func emit_shot_triggered() -> void:
	shot_triggered.emit()
