class_name StudentDebil extends Node2D

enum DRIP_ENUM {
	no_drip = -1,
	wust = 0
}

const HUNGRY_MOUTH = preload("uid://s4oy335pouwy")
const NERVE = preload("uid://bair1v1ji8sl1")
const NORMAL_EYES = preload("uid://ccpcxvgftxlfs")
const NORMAL_MOUTH = preload("uid://seove5hbkw1v")
const SLEEPY_EYES = preload("uid://l13ljpdithen")
const SWEAT = preload("uid://dt2dr5xvrylxm")

@export_group("Misc", "misc_")
@export_range(0, 100, 0.1) var health_threshold := 20.0
@export_range(0, 100, 0.1) var hungry_threshold := 35.0
@export_range(0, 100, 0.1) var bladder_threshold := 15.0
@export_range(0, 100, 0.1) var stress_threshold := 30.0
@export var misc_drip_sprites: Dictionary

@onready var student: Sprite2D = $Student
@onready var eye: Sprite2D = $Eye
@onready var mouth: Sprite2D = $Mouth
@onready var nerve: Sprite2D = $Nerve
@onready var sweat: Sprite2D = $Sweat
@onready var drip: Sprite2D = $Drip

var curr_drip := DRIP_ENUM.no_drip
var sleepy := false:
	set(b):
		if sleepy != b:
			if b:
				eye.texture = SLEEPY_EYES
			else:
				eye.texture = NORMAL_EYES
		sleepy = b
var hungry := false:
	set(b):
		if hungry != b:
			if b:
				mouth.texture = HUNGRY_MOUTH
			else:
				mouth.texture = NORMAL_MOUTH
		hungry = b
var making_piss := false:
	set(b):
		if making_piss != b:
			if b:
				sweat.visible = true
				sweat.texture = SWEAT
			else:
					sweat.visible = false
		making_piss = b
var stressed := false:
	set(b):
		if stressed != b:
			if b:
				nerve.visible = true
				nerve.texture = NERVE
			else:
				nerve.visible = false
		stressed = b

func _ready():
	var inst = PlayerMaster.instance
	inst.update_drip.connect(_update_drip)
	inst.health_threshold = health_threshold
	inst.hungry_threshold = hungry_threshold
	inst.bladder_threshold = bladder_threshold
	inst.stress_threshold = stress_threshold

func _exit_tree():
	PlayerMaster.instance.update_drip.disconnect(_update_drip)

func _check_needs(health: float, hunger: float, bladder: float, stress: float):
	sleepy = health < health_threshold
	hungry = hunger < hungry_threshold
	making_piss = bladder < bladder_threshold
	stressed = stress < stress_threshold

func _update_drip():
	var inst = PlayerMaster.instance
	drip.texture = null
	for key in inst.wearing_items.keys():
		var state = inst.wearing_items.get(key)
		if state <= 1:
			continue
		var item_group = GameMaster.instance._find_drip(key).debug_group_name
		print(key, ' ', misc_drip_sprites.keys())
		match item_group:
			"jacket":
				drip.texture = misc_drip_sprites.get(key)
