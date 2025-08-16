class_name SaveData extends Resource

@export var high_score : int = 0
@export var endless_score : int = 0
@export var diff_base : String = ""
@export var diff_endless : String = ""

const SAVE_PATH:String = "user://score_data.tres"

func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)

static func load_or_create() -> SaveData:
	var res:SaveData
	if FileAccess.file_exists(SAVE_PATH):
		res = load(SAVE_PATH) as SaveData
	else:
		res = SaveData.new()
	return res
