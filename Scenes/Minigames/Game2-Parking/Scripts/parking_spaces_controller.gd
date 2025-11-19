class_name Game2ParkingSpacesController extends Node2D

var available_parking_spaces: Array[Game2ParkingSpace]
var used_parking_spaces: Array[Game2ParkingSpace]
var active_parking_lot: Game2ParkingSpace = null

signal end_of_space

func _ready():
	for child in get_children():
		available_parking_spaces.push_back(child)

func _get_random_child(remove := false) -> Game2ParkingSpace:
	if available_parking_spaces.size() == 0:
		return null
	var rand_index = randi_range(0, available_parking_spaces.size() - 1)
	var child = available_parking_spaces[rand_index]
	if remove:
		used_parking_spaces.push_back(available_parking_spaces.pop_at(rand_index))
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
		end_of_space.emit()
		for i in range(0, used_parking_spaces.size()):
			available_parking_spaces.push_back(used_parking_spaces.pop_back())
