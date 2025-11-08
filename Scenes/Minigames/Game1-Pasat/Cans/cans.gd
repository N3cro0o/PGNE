class_name TinCans extends Game1Obstacle

@export var cans = 1

signal player_hit(value: int)

func _on_character_hit(area: Area2D):
	if area.is_in_group("player"):
		GameMaster.instance.tin_cans += cans
		player_hit.emit(cans)
		_reset()
