class_name Game2Vehicle extends Area2D

const PLAYER_VEHICLE_COLORS = [Color.WHITE, Color.BLUE_VIOLET, Color.GREEN_YELLOW,
	Color.WEB_PURPLE, Color.SLATE_GRAY, Color.AQUA]

@export var active = false
@onready var wheels: Sprite2D = $Wheel
@onready var wheel_scale = wheels.scale

signal hit_other_vehicle(area)

func _change_wheels(right := false):
	if right:
		wheels.scale.x = -wheel_scale.x
	else:
		wheels.scale.x = wheel_scale.x

func _on_vehicle_hit(area: Area2D):
	if !active:
		hit_other_vehicle.emit(area)

func _randomize_color():
	$Car.modulate = PLAYER_VEHICLE_COLORS.pick_random()
