class_name Game1Obstacle extends Area2D

@export var move_speed = 100.0
@export var active = false
@export var move_vec := Vector2.LEFT

@onready var real_move_speed = move_speed
@onready var start_position = position

func _process(delta):
	if active:
		position += move_vec * real_move_speed * delta

func _reset():
	active = false
	position = start_position
