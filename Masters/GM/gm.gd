class_name GameMaster extends Node2D

static var instance: GameMaster

#region Variables

@export var game_scenes: Array[PackedScene]

var in_game := false

#endregion

func _ready() -> void:
	instance = self

func _change_current_scene(id: int):
	get_tree().change_scene_to_packed(game_scenes[id])
