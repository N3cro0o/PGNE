class_name OptionsAndSaveManager extends Node2D

const SAVE_PATH = "user://save%d/pwr.wust"

class SaveData extends Node:
	var master := 0.0
	
	func _init(master_vol := 0.0):
		master = master_vol
	
	func _to_dictionary() -> Dictionary:
		return {
			"master": master
		}

var data: SaveData = null

signal load_done

func _ready():
	data = SaveData.new(0.0)
	print("OSM, ", data.master)
	var dsasd = var_to_bytes(data) 
	print(dsasd)
	print(bytes_to_var(dsasd) as SaveData)
	_load_savefile(0)

func _load_savefile(id: int):
	if _check_savefile(id):
		data = _get_savefile(id)
	load_done.emit()

func _get_savefile(id: int) -> SaveData:
	var _path = SAVE_PATH % id
	
	return SaveData.new(0.0)

func _check_savefile(id:int) -> bool:
	var path = SAVE_PATH % id
	if !OS.is_userfs_persistent():
		return false
	if FileAccess.file_exists(path):
		return true
	return false

func _store_savefile(id: int):
	var _path = SAVE_PATH % id
