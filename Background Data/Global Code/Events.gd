extends Node
signal enemy_hit(value : int)
signal ally_hit(value : int)
signal game_over
signal level_cleared
signal banana_tally(value : int)
signal power_up
signal shot_triggered
signal score_tally(value: int)
signal back_to_start_menu

var enable_banana_movement: bool = false
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

func emit_shot_triggered() -> void:
	print("emit shot triggered")
	shot_triggered.emit()

func emit_score_tally(value: int) -> void:
	score_tally.emit(value)
	
func emit_back_to_start_menu() -> void:
	back_to_start_menu.emit()
	
# To hopefull reduce leaks caused by custom mouse cursor (and maybe custom mouse events)
func _exit_tree() -> void:
	Input.set_custom_mouse_cursor(null)
