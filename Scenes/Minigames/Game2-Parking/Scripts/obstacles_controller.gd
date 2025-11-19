class_name Game2ObstacleController extends Node2D

var available_parking_spaces: Array[Game2MovingVehicle]
var used_parking_spaces: Array[Game2MovingVehicle]

func _ready():
	for child in get_children():
		if child is Game2MovingVehicle:
			available_parking_spaces.push_back(child)
			print(child.name)

func _get_random_child(remove := false) -> Game2MovingVehicle:
	if available_parking_spaces.size() == 0:
		return null
	var rand_index = randi_range(0, available_parking_spaces.size() - 1)
	var child = available_parking_spaces[rand_index]
	if remove:
		available_parking_spaces.pop_at(rand_index)
	return child

func _activate_random_vehicle():
	var vehicle = _get_random_child(true)
	if vehicle != null:
		vehicle.active = true
	_check_available_vehicles() 

func _check_available_vehicles():
	if available_parking_spaces.size() == 0:
		print("ADD LOGIC _check_available_vehicles")
