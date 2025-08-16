class_name LastSavedLevelData extends Resource

@export var current_score : int = 0
@export var current_level : String
@export var saved_difficulty: int = 0
@export var saved_lives_mode: int = 0
@export var saved_life_count: int = 0

const SAVE_PATH:String = "user://save_data.tres"

func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> LastSavedLevelData:
	var res:LastSavedLevelData
	if FileAccess.file_exists(SAVE_PATH):
		res = load(SAVE_PATH) as LastSavedLevelData
	else:
		res = LastSavedLevelData.new()
	return res
