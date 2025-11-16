extends Node2D

const VEHICLE_SCENE = preload("uid://cvnb0tyvpewaa")
const SPAWN_POINT = Vector2(90, 420)

@export_group("Vehicles", "veh_")
@export var veh_vehicle_speed := 100.0
@export var veh_vehicle_rotation := 2.0
@export_range(0, 10, 1) var veh_vehicle_parking_rotation := 5.0
@export var veh_current_vehicle: Game2Vehicle

@onready var parking_spaces: Game2ParkingSpacesController = $ParkingSpaces
@onready var vehicles: Node2D = $Vehicles
@onready var pause_menu: ColorRect = $Menu/Pause
@onready var game_over_menu: ColorRect = $Menu/GameOver

var movement_vec := Vector2.UP
var next_car: Game2Vehicle
var vehicle_thread: Thread
var finished_parkings: int = 0
var end_game := false:
	set(new_end_game):
		end_game = new_end_game
		@warning_ignore("integer_division")
		$Menu/GameOver/MarginContainer/VBoxContainer/VBoxContainer/CansLabel.text = can_label % (finished_parkings / 2)
		game_over_menu.visible = true
var paused := false:
	set(new_paused):
		paused = new_paused
		pause_menu.visible = paused
		if paused && !end_game:
			@warning_ignore("integer_division")
			$Menu/Pause/MarginContainer/VBoxContainer/CansLabel.text = can_label % (finished_parkings / 2)
		elif !end_game:
			pass
var can_label := "Collected %d tin cans"

func _ready():
	veh_current_vehicle.active = true
	veh_current_vehicle._randomize_color()
	vehicle_thread = Thread.new()
	vehicle_thread.start(_thread_spawn_new_vehicle)
	parking_spaces._activate_random_lot()

func _input(event: InputEvent):
	if event is InputEventKey && !paused:
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

func _thread_spawn_new_vehicle():
	var car := VEHICLE_SCENE.instantiate()
	car.visible = false
	car.position = SPAWN_POINT
	vehicles.call_deferred("add_child", car)
	next_car = car

func _get_next_vehicle():
	veh_current_vehicle.active = false
	veh_current_vehicle = next_car
	veh_current_vehicle.visible = true
	veh_current_vehicle.active = true
	veh_current_vehicle._randomize_color()
	veh_current_vehicle.hit_other_vehicle.connect(_check_collision)
	next_car = null
	vehicle_thread.wait_to_finish()
	vehicle_thread = Thread.new()
	vehicle_thread.start(_thread_spawn_new_vehicle)
	parking_spaces._activate_random_lot()

func _on_player_entering_parking():
	if _check_player_position():
		_get_next_vehicle()

func _check_player_position() -> bool:
	var rotat = (rad_to_deg(veh_current_vehicle.rotation) as int) % 180
	print("Angle: ", abs(rotat))
	return (abs(rotat) < veh_vehicle_parking_rotation || abs(rotat) > 180 - veh_vehicle_parking_rotation)

func _check_collision(area: Area2D):
	if area == veh_current_vehicle:
		end_game = true
