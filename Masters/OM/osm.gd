class_name OptionsAndSaveManager extends Node2D
static var instance: OptionsAndSaveManager

const SAVE_PATH = "user://save%d/"
const SAVE_FILE = "pwr.wust"
const OPTIONS_FILE = "user://config.wust"

class SaveOptionData extends Node:
	var master := 0.0
	var localization := LocalizationMaster.LOCAL.English
	var mobile_toggle := false
	
	func _init(master_vol := 0.0):
		master = master_vol
	
	func _to_dictionary() -> Dictionary:
		return {
			"master": master,
			"localization": localization,
			"mobile_toggle": mobile_toggle
		}
	
	static func _from_dictionary(dict: Dictionary) -> SaveOptionData:
		var output = SaveOptionData.new()
		var keys = dict.keys()
		if keys.find("master") != -1:
			output.master = dict["master"]
		if keys.find("localization") != -1:
			output.localization = dict["localization"]
		if keys.find("mobile_toggle") != -1:
			output.mobile_toggle = dict["mobile_toggle"]
		return output

class SavefileData extends Node:
	var cans := 0
	var health := 100.0
	var bladder := 100.0
	var stress := 100.0
	var hunger := 100.0
	
	var fridge := {
		"bread": 3,
		"piwko": 2,
		"hotdog": 0,
		"pizza": 1,
		"burtella": 0
	}
	
	func _to_dictionary() -> Dictionary:
		return {
			"cans": cans,
			"health": health,
			"bladder": bladder,
			"stress": stress,
			"hunger": hunger,
			"fridge": fridge,
		}
	
	static func _from_dictionary(dict: Dictionary) -> SavefileData:
		var output = SavefileData.new()
		var keys = dict.keys()
		if keys.find("cans") != -1:
			output.cans = dict["cans"]
		if keys.find("health") != -1:
			output.health = dict["health"]
		if keys.find("bladder") != -1:
			output.bladder = dict["bladder"]
		if keys.find("stress") != -1:
			output.stress = dict["stress"]
		if keys.find("hunger") != -1:
			output.hunger = dict["hunger"]
		if keys.find("fridge") != -1:
			output.fridge = dict["fridge"]
		return output

var data: SaveOptionData = null
var game_datas: Array[SavefileData]
var curr_savefile = 0

signal load_done

static func _SAVE():
	var inst = OptionsAndSaveManager.instance
	inst._store_optionfile(inst.data)
	inst._store_gamedata(inst.curr_savefile, inst.game_datas[inst.curr_savefile])

static func _RETURN_CURR_SAVEDATA() -> SavefileData:
	var inst = OptionsAndSaveManager.instance
	return inst.game_datas[inst.curr_savefile]

func _ready():
	instance = self
	for i in 3:
		game_datas.push_back(SavefileData.new())
	data = SaveOptionData.new(1.0)
	_load_all()
	print(data._to_dictionary())

func _load_all():
	_load_optionfile()
	_load_gamedata_all()
	_setup_data()
	load_done.emit()

#region Option funcs

func _load_optionfile():
	if _check_optionfile():
		data = _get_optionfile()
	else:
		data = _store_optionfile()

func _get_optionfile() -> SaveOptionData:
	var loaded_data = FileAccess.get_file_as_bytes(OPTIONS_FILE)
	return SaveOptionData._from_dictionary(bytes_to_var(loaded_data))

func _check_optionfile() -> bool:
	if !OS.is_userfs_persistent():
		return false
	if FileAccess.file_exists(OPTIONS_FILE):
		return true
	return false

func _store_optionfile(data_var := SaveOptionData.new(1.0)) -> SaveOptionData:
	var file = FileAccess.open(OPTIONS_FILE, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(data_var._to_dictionary()))
	return data_var

#endregion

#region GameData funcs:

func _load_gamedata_all():
	for i in 3:
		if _check_gamedata(i):
			game_datas[i] = _get_gamedata(i)
		else:
			game_datas[i] = _store_gamedata(i)

func _get_gamedata(id: int) -> SavefileData:
	var path = (SAVE_PATH % id) + SAVE_FILE
	var loaded_data = FileAccess.get_file_as_bytes(path)
	return SavefileData._from_dictionary(bytes_to_var(loaded_data))

func _check_gamedata(id: int) -> bool:
	var path = (SAVE_PATH % id) + SAVE_FILE
	if !OS.is_userfs_persistent():
		return false
	return FileAccess.file_exists(path)

func _store_gamedata(id: int, data_var := SavefileData.new()):
	var path = (SAVE_PATH % id) + SAVE_FILE
	if !_check_gamedata(id):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH % id)
	print(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(var_to_bytes(data_var._to_dictionary()))
	return data_var

#endregion

func _setup_data():
	var data_to_load = game_datas[curr_savefile]
	GameMaster.instance.tin_cans = data_to_load.cans
	var p_inst = PlayerMaster.instance
	p_inst.health = data_to_load.health
	p_inst.bladder = data_to_load.bladder
	p_inst.stress = data_to_load.stress
	p_inst.hunger = data_to_load.hunger
	PlayerMaster.fridge = data_to_load.fridge
