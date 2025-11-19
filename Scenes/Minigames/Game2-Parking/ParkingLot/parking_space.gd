class_name Game2ParkingSpace extends Area2D

enum TYPE {
	Horizontal,
	Vertical
}

@export var active = false:
	set(b):
		active = b
		queue_redraw()
@export var lot_type: TYPE = TYPE.Vertical
@export_range(0, 25) var radius := 5.0
@export var color := Color.WHITE

@onready var collision: CollisionShape2D = $Collision

signal player_inside(lot_type: TYPE)

func _ready():
	collision.shape.radius = radius

func _draw():
	if active:
		draw_circle(Vector2.ZERO, radius, color)

func _parking_check(area: Area2D):
	if area.is_in_group("player") && active:
		player_inside.emit(lot_type)
