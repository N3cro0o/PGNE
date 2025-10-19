class_name MainMenu extends Control

#region Variables

@onready var bg: TextureRect = $BG

#endregion

func _process(delta):
	bg.rotation += 1 * delta
	
func _start_button_pressed():
	GameMaster.instance.in_game = true
	GameMaster.instance._change_current_scene(1)
