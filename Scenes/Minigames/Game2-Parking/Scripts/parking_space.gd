class_name Game2ParkingSpace extends Node2D

@export_range(0, 25) var radius := 5.0
@export var color := Color.WHITE

func _draw():
	draw_circle(position, radius, color)
