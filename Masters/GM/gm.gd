class_name GameMaster extends Node2D

static var instance: GameMaster

#region Variables

@export var game_scenes: Array[PackedScene]
@export var shop_items: Array[ShopItem]
@export var shop_drip_items: Array[ShopItemDrip]
@export var game_events: Array[EventHolder]
@export var threading_check = false
@export var can_multi_base = 1.0
@export var can_multi_punishment_multi = 0.1
@export var event_timer_mins := 5
@export_range(0.0, 1.0, 0.01) var event_chance := 0.4

@onready var timer: Timer = $Timer
@onready var event_timer: Timer = $Timer2

var can_multi_punishment_count = 0:
	set(x):
		if x == can_multi_punishment_count:
			return
		can_multi_punishment_count = x
		can_multi = can_multi_base - can_multi_punishment_multi * x
var can_multi = can_multi_base
var tin_cans := 0:
	set(can):
		if can >= 0:
			var diff = can - tin_cans
			if diff <= 0:
				tin_cans = can
			else:
				@warning_ignore("narrowing_conversion")
				tin_cans += diff * can_multi
			OptionsAndSaveManager._RETURN_CURR_SAVEDATA().cans = tin_cans
var in_game := false:
	set(b):
		in_game = b
		timer.paused = !in_game
		event_timer.paused = !in_game
var boosted_drops = false

var local_strings_names

signal event_started(event: EventHolder)

#endregion

func _ready() -> void:
	instance = self
	await OSM.load_done
	timer.start()
	timer.paused = true
	event_timer.start(event_timer_mins * 60)
	event_timer.paused = true

func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.as_text_keycode() == "F1" && event.is_pressed():
				boosted_drops = true
			elif event.as_text_keycode() == "F1" && event.is_released():
				boosted_drops = false

func _change_current_scene(id: int):
	get_tree().change_scene_to_packed(game_scenes[id])

func _autosave():
	print("Autosave! - ", Time.get_datetime_string_from_system())
	OptionsAndSaveManager._SAVE()

func _find_drip(key: String) -> ShopItemDrip:
	for items in shop_drip_items:
		if items.debug_name == key:
			return items
	return null
	
func _find_event(key: String) -> EventHolder:
	for items in game_events:
		if items.debug_name == key:
			return items
	return null

func _get_similar_drip(group: String, item_name: String):
	var group_arr = []
	for item in shop_drip_items:
		if item.debug_group_name == group && item.debug_name != item_name:
			group_arr.push_back(item.debug_name)
	return group_arr

func _spawn_event():
	print("Get new event...")
	var in_event = PlayerMaster.instance.in_event
	if randf() <= event_chance && in_game && !in_event:
		var event = game_events.pick_random()
		print("New event: ", event.debug_name)
		event_started.emit(event)
	else:
		print("Fail!")
