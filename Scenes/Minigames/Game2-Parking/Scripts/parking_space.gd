class_name Game2ParkingSpace extends Area2D

@export var active = false:
	set(b):
		active = b
		queue_redraw()
@export_range(0, 25) var radius := 5.0
@export var color := Color.WHITE

@onready var collision: CollisionShape2D = $Collision

signal player_inside

func _ready():
	collision.shape.radius = radius

func _draw():
	if active:
		draw_circle(Vector2.ZERO, radius, color)

func _parking_check(area: Area2D):
	if area.is_in_group("player"):
		player_inside.emit()
