class_name LocalizationMaster extends Node2D

static var instance: LocalizationMaster

static var LOCALIATION_NAMES = {
	LOCAL.English: "en",
	LOCAL.Polish: "pl",
	LOCAL.Ślōnsko_Godka: "sil",
}

enum LOCAL {
	English,
	Polish,
	Ślōnsko_Godka
}

const LOCAL_DIR = "res://Locals/"

var loaded_data: Dictionary

func _ready():
	instance = self
	_load_localization(OptionsAndSaveManager.instance.data.localization)

func _load_localization(which: LOCAL):
	var file_path = LOCAL_DIR + LOCALIATION_NAMES[which] + ".json"
	if !FileAccess.file_exists(file_path):
		_load_localization(LOCAL.English)
		return
	var file = FileAccess.open(file_path, FileAccess.READ)
	var str_json = file.get_as_text()
	loaded_data = JSON.parse_string(str_json)

static func _GET_VALUE(debug_name: String) -> String:
	var output := debug_name
	if LocalizationMaster.instance.loaded_data.find_key(debug_name) != -1:
		output = LocalizationMaster.instance.loaded_data[debug_name]
	return output
