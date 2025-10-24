class_name GameMaster extends Node2D

static var instance: GameMaster

#region Variables

@export var game_scenes: Array[PackedScene]
@export var shop_items: Array[ShopItem]

var tin_cans := 0
var in_game := false
var boosted_drops = false

#endregion

func _ready() -> void:
	instance = self

func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.as_text_keycode() == "F1" && event.is_pressed():
				boosted_drops = true
			elif event.as_text_keycode() == "F1" && event.is_released():
				boosted_drops = false

func _change_current_scene(id: int):
	get_tree().change_scene_to_packed(game_scenes[id])
