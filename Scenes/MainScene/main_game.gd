class_name MainGame extends Node2D

#region Variables

@export var game_backgrounds: Array[GameBg]

@onready var bg: Sprite2D = $BG
@onready var game_tabs: TabContainer = $GameTabs
@onready var ziutek: Sprite2D = $GameTabs/Akademyk/Ziutek

var base_pos_y: float
var time := 0.0
#endregion

func _physics_process(delta: float) -> void:
	if (randf() > 0.9995 && !GameMaster.instance.boosted_drops) || \
	(randf() > 0.90 && GameMaster.instance.boosted_drops): # 0.9995 ^ 20 = ~ 0.99
		GameMaster.instance.tin_cans += 1
		print("New can")
	time += delta / 4
	ziutek.position.y = base_pos_y + (sin(time) * 5)

func _update_bg(id: int):
	var picked := game_backgrounds[id]
	bg.texture = picked.image
	bg.position = picked.position
	bg.scale = picked.scale

func _ready():
	akademyk_button()
	base_pos_y = ziutek.position.y

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

func update_fridge():
	if PlayerMaster.fridge["bread"] > 0:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Chlib.visible = true
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Chlib.text = "Stale bread %d" % PlayerMaster.fridge["bread"]
	else:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Chlib.visible = false
	if PlayerMaster.fridge["piwko"] > 0:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Piwko.visible = true
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Piwko.text = "Piwko 12.3%% %d" % PlayerMaster.fridge["piwko"]
	else:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Piwko.visible = false
	if PlayerMaster.fridge["hotdog"] > 0:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.visible = true
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.text = "Hot-dog %d" % PlayerMaster.fridge["hotdog"]
	else:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.visible = false
	if PlayerMaster.fridge["pizza"] > 0:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.visible = true
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.text = "Pizza pepperoni %d" % PlayerMaster.fridge["pizza"]
	else:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.visible = false
	if PlayerMaster.fridge["burtella"] > 0:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Burtella.visible = true
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Burtella.text = "Burtella %d" % PlayerMaster.fridge["burtella"]
	else:
		$GameTabs/Jadlodalnia/Limit/ColorRect/Margin/Box/Content/ContentVBox/Burtella.visible = false


#region Button functions

func quit_button():
	GameMaster.instance.in_game = false
	GameMaster.instance._change_current_scene(0)

func akademyk_button():
	game_tabs.current_tab = 0
	_update_bg(0)

func sracz_button():
	game_tabs.current_tab = 1
	_update_bg(1)

func jadlo_button():
	game_tabs.current_tab = 2
	_update_bg(2)

func office_button():
	game_tabs.current_tab = 3
	_update_bg(3)
	
func _loduwa_button(id: int):
	print("Eat: %d" % id)
	var item = GameMaster.instance.shop_items[id]
	var count = PlayerMaster.fridge[item.debug_name]
	if count > 0:
		PlayerMaster.fridge[item.debug_name] -= 1
		add_hunger(item.extra_param)
		# Secrets
		if item.debug_name == "pizza":
			print("PIZZA PEPPERONI")
			var audio := $AudioStreamPlayer
			audio.play()
		# Update
		update_fridge()

func _toggle_fridge():
	$GameTabs/Jadlodalnia/Limit.visible = true
	update_fridge()

func _hide_menus():
	$GameTabs/Jadlodalnia/Limit.visible = false
	
func _get_mouse_click(event: InputEvent):
	if event.is_pressed() && event is InputEventMouseButton:
		_hide_menus()

#endregion
