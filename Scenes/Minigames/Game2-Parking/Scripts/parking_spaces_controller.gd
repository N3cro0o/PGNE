class_name Game2ParkingSpacesController extends Node2D

var available_parking_spaces: Array[Game2ParkingSpace]
var used_parking_spaces: Array[Game2ParkingSpace]
var active_parking_lot: Game2ParkingSpace = null

func _ready():
	for child in get_children():
		available_parking_spaces.push_back(child)

func _get_random_child(remove := false) -> Game2ParkingSpace:
	if available_parking_spaces.size() == 0:
		return null
	var rand_index = randi_range(0, available_parking_spaces.size() - 1)
	var child = available_parking_spaces[rand_index]
	if remove:
		available_parking_spaces.pop_at(rand_index)
	return child

func _activate_random_lot():
	if active_parking_lot != null:
		active_parking_lot.active = false
	active_parking_lot = _get_random_child(true)
	if active_parking_lot != null:
		active_parking_lot.active = true
	_check_available_lots() 

func _check_available_lots():
	if available_parking_spaces.size() == 0:
		print("ADD LOGIC _check_available_lots")
