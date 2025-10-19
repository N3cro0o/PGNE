class_name MainGame extends Node2D

#region Variables

#endregion

#region Button functions

func quit_button():
	GameMaster.instance.in_game = false
	GameMaster.instance._change_current_scene(0)

#endregion
