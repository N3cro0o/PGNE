class_name MainMenu extends Control

#region Variables

@export var rotation_speed: Curve
@onready var bg: TextureRect = $BG

var t: float:
	set(x):
		if x > 1:
			t = 0
		else:
			t = x

#endregion

func _process(delta):
	t += delta / 10
	bg.rotation += rotation_speed.sample(t) * delta / 4
	
func _start_button_pressed():
	GameMaster.instance.in_game = true
	GameMaster.instance._change_current_scene(1)
