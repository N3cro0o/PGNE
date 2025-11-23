class_name PlayerMaster extends Node2D

static var instance: PlayerMaster
#TODO Add piwko count... somewhere
static var fridge := {
	"bread": 3,
	"piwko": 2,
	"hotdog": 0,
	"pizza": 1,
	"burtella": 0
}:
	set(new_fridge):
		fridge = new_fridge
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().fridge = new_fridge

#region Variables

@export var force_start := false
@export_category("Stats")
@export var max_health: float = 100
@export var max_hunger: float = 100
@export var max_bladder: float = 100
@export var max_stress: float = 100
@export_category("Multiplier")
@export var health_multi: float = 0.8
@export var hunger_multi: float = 1
@export var bladder_multi: float = 1.2
@export var stress_multi: float = 1

var health: float = 100:
	set(hp):
		if hp < 0:
			health = 0
		elif hp > max_health:
			health = max_health
		else:
			health = hp
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().health = health
var hunger: float = 100:
	set(hg):
		if hg < 0:
			hunger = 0
		elif hg > max_hunger:
			hunger = max_hunger
		else:
			hunger = hg
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().hunger = hunger
var bladder: float = 100:
	set(bl):
		if bl < 0:
			bladder = 0
		elif bl > max_bladder:
			bladder = max_bladder
		else:
			bladder = bl
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().bladder = bladder
var stress: float = 100:
	set(sr):
		if sr < 0:
			stress = 0
		elif sr > max_stress:
			stress = max_stress
		else:
			stress = sr
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().stress = stress
var health_threshold := 20.0
var hungry_threshold := 35.0
var bladder_threshold := 15.0
var stress_threshold := 30.0
var wait_multi = 1.0
var wait_time := 0.0:
	set(t):
		if wait_time > 0 && t < 0.05:
			if working_on_event:
				in_event = false
				curr_event = null
			wait_multi = 1.0
			wait_time = 0.0
			wait_time_state.emit(false)
		elif wait_time == 0 && t > 0:
			wait_multi = 0.1
			wait_time = t
			wait_time_state.emit(true)
		else:
			wait_time = t
		if wait_time < 0: wait_time = 0
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().wait_time = wait_time
var wearing_items: Dictionary
var in_event = false:
	set(state):
		in_event = state
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().in_event = state
var curr_event: EventHolder:
	set(event):
		curr_event = event
		if event != null:
			OptionsAndSaveManager._RETURN_CURR_SAVEDATA().event_debug_name = event.debug_name
		else:
			OptionsAndSaveManager._RETURN_CURR_SAVEDATA().event_debug_name = ""
var working_on_event = false

signal wait_time_state(state: bool)
signal update_drip

#endregion

func _ready() -> void:
	instance = self
	for item in GameMaster.instance.shop_drip_items:
		var item_name = item.debug_name
		wearing_items.set(item_name, 0)
	GameMaster.instance.event_started.connect(_get_event)

func _process(delta: float) -> void:
	if force_start || GameMaster.instance.in_game:
		health -= health_multi * delta * wait_multi
		hunger -= hunger_multi * delta * wait_multi
		bladder -= bladder_multi * delta * wait_multi
		stress -= stress_multi * delta * wait_multi
		# Threshold check
		var count = 0
		if health < health_threshold:
			count += 1
		if hunger < hungry_threshold:
			count += 1
		if bladder < bladder_threshold:
			count += 1
		if stress < stress_threshold:
			count += 1
		GameMaster.instance.can_multi_punishment_count = count

func _update_wardrobe(key: String, check: int) -> bool:
	if wearing_items.keys().find(key) == -1:
		return false
	if check:
		var curr_item = GameMaster.instance._find_drip(key)
		for old_key in GameMaster.instance._get_similar_drip(curr_item.debug_group_name, curr_item.debug_name):
			if wearing_items.get(old_key, 0) > 0:
				print("Removing... ", old_key)
				wearing_items.set(old_key, 1)
	wearing_items.set(key, check)
	var data = OptionsAndSaveManager._RETURN_CURR_SAVEDATA()
	data.wardrobe.set(key, check)
	update_drip.emit()
	return true

func _get_event(event):
	working_on_event = false
	curr_event = event
	in_event = true

func _load_event(debug_name: String):
	curr_event = GameMaster.instance._find_event(debug_name)
