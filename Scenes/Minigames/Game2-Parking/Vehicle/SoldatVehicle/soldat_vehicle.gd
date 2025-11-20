class_name Game2MovingVehicle extends Game2Vehicle

@export var path_line: Line2D
@export_range(0, 10, 1) var move_priority := 5.0
@export var finish_line_reset := false
@export var speed := 100.0

var game_speed = 1.0
var real_speed = speed
var path_index = 1:
	set(i):
		if i >= path_line.get_point_count():
			if finish_line_reset:
				path_index = 0
				position = path_line.get_point_position(0)
			else:
				reverse_order = true
				path_index -= 1
		elif i < 0:
			reverse_order = false
			path_index += 1
		else:
			path_index = i
var reverse_order := false
var speed_vec: Vector2
var number_of_soldats = 0:
	set(num):
		if num > 0:
			real_speed = 0
		else:
			real_speed = speed
		if num < 0:
			number_of_soldats = 0
		else:
			number_of_soldats = num
		print(name, ' ', number_of_soldats)
var stop_timer := 0.0

signal hit_other_vehicle_better(area, b)

func _ready():
	_set_active(false)

func _set_active(b: bool):
	super(b)
	car.visible = b
	if b:
		speed_vec = (path_line.get_point_position(path_index) - position).normalized()
		rotation = speed_vec.angle() + PI/2

func _process(delta):
	if number_of_soldats > 0:
		stop_timer += delta
		if stop_timer > move_priority:
			stop_timer = 0.0
			path_index -= 1
			speed_vec = (path_line.get_point_position(path_index) - position).normalized()
			rotation = speed_vec.angle() + PI/2
			number_of_soldats = 0
		else:
			stop_timer -= delta / 3
	if active:
		if path_line == null:
			active = false
			return
		if position.distance_squared_to(path_line.get_point_position(path_index)) <= 9:
			if reverse_order:
				path_index -= 1
			else:
				path_index += 1
			speed_vec = (path_line.get_point_position(path_index) - position).normalized()
			rotation = speed_vec.angle() + PI/2
		position += speed_vec * real_speed * delta * game_speed

func _on_vehicle_hit(area: Area2D):
	if active:
		hit_other_vehicle_better.emit(area, true)

func _soldat_lookup_logic(area: Area2D):
	if area is Game2MovingVehicle:
		print(area.name, ' ', area.move_priority, ' ', area.active)
		if area.move_priority == move_priority || !area.active || area == self:
			return
		number_of_soldats += 1

func _soldat_reset(area: Area2D):
	if area is Game2MovingVehicle:
		if area.move_priority == move_priority || !area.active || area == self:
			return
		number_of_soldats -= 1
