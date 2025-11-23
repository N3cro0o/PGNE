class_name MainGame extends Node2D

#region Variables

@export var game_backgrounds: Array[GameBg]
@export var random_ziutek_line: Curve
@export var buttons: Array[PolygonButton2D]

@onready var bg: Sprite2D = $BG
@onready var game_tabs: TabContainer = $GameTabs
@onready var ziutek: Sprite2D = $GameTabs/Akademyk/Ziutek
@onready var loduwa_menu: MarginContainer = $GameTabs/Jadlodalnia/LoduwaMenu
@onready var toggle_bridge: PolygonButton2D = $GameTabs/Jadlodalnia/ToggleBridge
@onready var student_pet: StudentDebil = $GameTabs/Akademyk/StudentPet
@onready var menus: MainGameUI = $MainGameUI

var base_pos_y: float
var time := 0.0
var line_time := 0.0:
	set(x):
		if x > 1.0:
			line_time = 0
		else:
			line_time = x

#endregion

func _physics_process(delta: float) -> void:
	if (randf() > 0.9995 && !GameMaster.instance.boosted_drops) || \
	(randf() > 0.90 && GameMaster.instance.boosted_drops): # 0.9995 ^ 20 = ~ 0.99
		GameMaster.instance.tin_cans += 1
		print("New can")
	time += delta / 4
	line_time += delta / 8
	student_pet.position.y = base_pos_y + (sin(time) * 5)
	ziutek.material.set_shader_parameter("width", random_ziutek_line.sample(line_time))
	_update_debil()
	menus._update_wait_panel(PlayerMaster.instance.wait_time)
	if PlayerMaster.instance.wait_time >= 0:
		PlayerMaster.instance.wait_time -= delta

func _update_bg(id: int):
	var picked := game_backgrounds[id]
	bg.texture = picked.image
	bg.position = picked.position
	bg.scale = picked.scale
	_hide_menus()

func _ready():
	PlayerMaster.instance.wait_time_state.connect(_wait_update_buttons)
	akademyk_button()
	base_pos_y = student_pet.position.y
	_localize()
	_update_debil()
	if PlayerMaster.instance.wait_time > 0:
		_wait_update_buttons(true)
	GameMaster.instance.event_started.connect(_get_event)
	if PlayerMaster.instance.in_event && PlayerMaster.instance.wait_time <= 0.0:
		_get_event(PlayerMaster.instance.curr_event)

func _exit_tree():
	PlayerMaster.instance.wait_time_state.disconnect(_wait_update_buttons)
	GameMaster.instance.event_started.disconnect(_get_event)

#region Functional functions

func add_hp(inst: PolygonButton2D, hp: int):
	if inst != null && inst.broken:
		PlayerMaster.instance.wait_time = PlayerMaster.instance.curr_event.block_for
		PlayerMaster.instance.working_on_event = true
		inst.broken = false
		menus._update_event_label()
		return
	PlayerMaster.instance.health += hp
	_check_and_wait(inst, 150)

func add_bladder(inst: PolygonButton2D, bl: int):
	if inst != null && inst.broken:
		PlayerMaster.instance.wait_time = PlayerMaster.instance.curr_event.block_for
		PlayerMaster.instance.working_on_event = true
		inst.broken = false
		menus._update_event_label()
		return
	PlayerMaster.instance.bladder += bl
	_check_and_wait(inst, 60)

func add_stress(inst: PolygonButton2D, st: int): # This shi does not make sense but let's just ignore it
	if inst != null && inst.broken:
		PlayerMaster.instance.wait_time = PlayerMaster.instance.curr_event.block_for
		PlayerMaster.instance.working_on_event = true
		inst.broken = false
		menus._update_event_label()
		return
	PlayerMaster.instance.stress += st
	_check_and_wait(inst, 10)

func add_hunger(inst: PolygonButton2D, hg: int):
	if inst != null && inst.broken:
		PlayerMaster.instance.wait_time = PlayerMaster.instance.curr_event.block_for
		PlayerMaster.instance.working_on_event = true
		inst.broken = false
		menus._update_event_label()
		return
	PlayerMaster.instance.hunger += hg
	_check_and_wait(inst, 300)

func _check_and_wait(inst: PolygonButton2D, wtime: float):
	if inst != null:
		PlayerMaster.instance.wait_time = wtime

func _wait_update_buttons(b: bool):
	for bttn in buttons:
		bttn.blocked = b
#endregion

func update_fridge():
	if PlayerMaster.fridge["bread"] > 0:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Chlib.visible = true
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Chlib.text = "Stale bread %d" % PlayerMaster.fridge["bread"]
	else:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Chlib.visible = false
		
	#if PlayerMaster.fridge["piwko"] > 0:
		#$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Piwko.visible = true
		#$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Piwko.text = "Piwko 12.3%% %d" % PlayerMaster.fridge["piwko"]
	#else:
		#$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Piwko.visible = false
	if PlayerMaster.fridge["hotdog"] > 0:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.visible = true
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.text = "Hot-dog %d" % PlayerMaster.fridge["hotdog"]
	else:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers.visible = false
		
	if PlayerMaster.fridge["pizza"] > 0:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.visible = true
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.text = "Pizza pepperoni %d" % PlayerMaster.fridge["pizza"]
	else:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka.visible = false
		
	if PlayerMaster.fridge["burtella"] > 0:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Burtella.visible = true
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Burtella.text = "Burtella %d" % PlayerMaster.fridge["burtella"]
	else:
		$GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Burtella.visible = false

func _update_piwko():
	if PlayerMaster.fridge["piwko"] > 0:
		$GameTabs/HomeOffice/Relaxxxxx.active = true
	else:
		$GameTabs/HomeOffice/Relaxxxxx.active = false

func _update_debil():
	var inst = PlayerMaster.instance
	student_pet._check_needs(inst.health, inst.hunger, inst.bladder, inst.stress)

#region Button functions

func _start_minigame(id: int):
	# End processes logic
	GameMaster.instance._change_current_scene(id + 2)

func _drink_piwko(_inst: PolygonButton2D):
	if PlayerMaster.fridge["piwko"] > 0:
		PlayerMaster.fridge["piwko"] -= 1
		add_bladder(null, -15)
		add_stress(null, 30)
		SoundEffectMaster._PLAY_BY_NAME("piwko")
	_update_piwko()

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
	_update_piwko()
	_update_bg(3)

func _loduwa_button(id: int):
	print("Eat: %d" % id)
	var item = GameMaster.instance.shop_items[id]
	var count = PlayerMaster.fridge[item.debug_name]
	if count > 0:
		PlayerMaster.fridge[item.debug_name] -= 1
		add_hunger(null, item.extra_param)
		# Secrets
		if item.debug_name == "pizza":
			print("PIZZA PEPPERONI")
			SoundEffectMaster._PLAY_BY_NAME("pizza_pepperoni")
		else:
			SoundEffectMaster._PLAY_BY_NAME("eat")
		# Update
		update_fridge()

func _toggle_fridge(_inst: PolygonButton2D):
	loduwa_menu.visible = true
	toggle_bridge.visible = false
	update_fridge()
	
func _show_shop():
	menus.shop_enter()
	$GameTabs/Akademyk/Ziutek.visible = false
	$GameTabs/Akademyk/AMiMir.visible = false
	$GameTabs/Akademyk/Shop.visible = false

func _hide_shop():
	$GameTabs/Akademyk/Ziutek.visible = false
	$GameTabs/Akademyk/AMiMir.visible = true
	$GameTabs/Akademyk/Shop.visible = true

func _show_game_center(_inst: PolygonButton2D):
	menus.game_center_enter()
	$GameTabs/HomeOffice/Relaxxxxx.visible = false
	$GameTabs/HomeOffice/Gaming.visible = false

func _hide_game_center():
	$GameTabs/HomeOffice/Relaxxxxx.visible = true
	$GameTabs/HomeOffice/Gaming.visible = true

func _hide_menus():
	loduwa_menu.visible = false
	toggle_bridge.visible = true
	
func _get_mouse_click(event: InputEvent):
	if event.is_pressed() && event is InputEventMouseButton:
		pass

#endregion

func _get_event(event: EventHolder):
	var bttn: PolygonButton2D
	match event.which:
		EventHolder.ROOM.AKADEMYK:
			bttn = buttons[0]
			bttn.broken = true
		EventHolder.ROOM.SRACZ:
			bttn = buttons[1]
			bttn.broken = true
		EventHolder.ROOM.JADLODALNIA:
			bttn = buttons[2]
			bttn.broken = true
		EventHolder.ROOM.HOME_OFFICE:
			bttn = buttons[3]
			bttn.broken = true
	menus._update_event_label(event.debug_event_label_name, true)

func _localize():
	var food_0 = $GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Chlib
	var food_1 = $GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Piwko
	var food_2 = $GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Hotdoggers
	var food_3 = $GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/PizzaZabka
	var food_4 = $GameTabs/Jadlodalnia/LoduwaMenu/ColorRect/Margin/Box/Content/ContentVBox/Burtella
	food_0.text = LocalizationMaster._GET_VALUE("chlib")
	food_1.text = LocalizationMaster._GET_VALUE("piwko")
	food_2.text = LocalizationMaster._GET_VALUE("hotdog")
	food_3.text = LocalizationMaster._GET_VALUE("pizza")
	food_4.text = LocalizationMaster._GET_VALUE("burtella")
