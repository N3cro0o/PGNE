class_name Game2Vehicle extends Area2D

@onready var wheels: Sprite2D = $Wheel

@onready var wheel_scale = wheels.scale

func _change_wheels(right := false):
	if right:
		wheels.scale.x = -wheel_scale.x
	else:
		wheels.scale.x = wheel_scale.x
