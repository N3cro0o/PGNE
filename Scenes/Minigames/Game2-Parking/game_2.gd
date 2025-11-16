extends Node2D

@export_group("Vehicles", "veh_")
@export var veh_vehicle_speed := 100.0
@export var veh_vehicle_rotation := 2.0
@export var veh_current_vehicle: Game2Vehicle

var movement_vec := Vector2.UP

func _input(event: InputEvent):
	if event is InputEventKey:
		var text = event.as_text_keycode()
		if text == "Right" || text == "Left":
			veh_current_vehicle.wheels.visible = event.is_pressed()
		if text == "Right":
			veh_current_vehicle._change_wheels(true)
		if text == "Left":
			veh_current_vehicle._change_wheels(false)


func _process(delta):
	if Input.is_key_pressed(KEY_UP):
		veh_current_vehicle.position += movement_vec.rotated(veh_current_vehicle.rotation) * veh_vehicle_speed * delta
		_handle_rotation(delta)
	if Input.is_key_pressed(KEY_DOWN):
		veh_current_vehicle.position += movement_vec.rotated(veh_current_vehicle.rotation) * -veh_vehicle_speed * delta
		_handle_rotation(delta, true)

func _handle_rotation(delta: float, invert := false):
	var i = 1
	if !invert:
		i = -1
	if Input.is_key_pressed(KEY_LEFT):
		veh_current_vehicle.rotation += i * delta * veh_vehicle_rotation
	if Input.is_key_pressed(KEY_RIGHT):
		veh_current_vehicle.rotation += i * delta * -veh_vehicle_rotation
