class_name GameMaster extends Node2D

static var instance: GameMaster

#region Variables

@export var game_scenes: Array[PackedScene]
@export var shop_items: Array[ShopItem]

@onready var timer: Timer = $Timer

var tin_cans := 0:
	set(can):
		if can >= 0:
			tin_cans = can
			OptionsAndSaveManager._RETURN_CURR_SAVEDATA().cans = can
var in_game := false:
	set(b):
		in_game = b
		timer.paused = !in_game
var boosted_drops = false

var local_strings_names

#endregion

func _ready() -> void:
	instance = self
	await OSM.load_done
	timer.start()
	timer.paused = true

func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.as_text_keycode() == "F1" && event.is_pressed():
				boosted_drops = true
			elif event.as_text_keycode() == "F1" && event.is_released():
				boosted_drops = false

func _change_current_scene(id: int):
	get_tree().change_scene_to_packed(game_scenes[id])

func _autosave():
	print("Autosave! - ", Time.get_datetime_string_from_system())
	OptionsAndSaveManager._SAVE()
