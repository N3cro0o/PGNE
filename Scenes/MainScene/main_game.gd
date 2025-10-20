class_name MainGame extends Node2D

#region Variables

@onready var bg: Sprite2D = $BG
@onready var game_tabs: TabContainer = $GameTabs

#endregion

#region Functional functions

func add_hp(hp: int):
	PlayerMaster.instance.health += hp

func add_bladder(bl: int):
	PlayerMaster.instance.bladder += bl

func add_stress(st: int): # This shi does not make sense but let's just ignore it
	PlayerMaster.instance.stress += st

func add_hunger(hg: int):
	PlayerMaster.instance.hunger += hg

#endregion

#region Button functions

func quit_button():
	GameMaster.instance.in_game = false
	GameMaster.instance._change_current_scene(0)

func akademyk_button():
	bg.modulate = Color.WHITE
	game_tabs.current_tab = 0

func sracz_button():
	bg.modulate = Color.YELLOW
	game_tabs.current_tab = 1

func jadlo_button():
	bg.modulate = Color.RED
	game_tabs.current_tab = 2

func office_button():
	bg.modulate = Color.BLUE
	game_tabs.current_tab = 3

#endregion
