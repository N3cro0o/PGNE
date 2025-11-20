extends Node2D

const VEHICLE_SCENE = preload("uid://cvnb0tyvpewaa")
const SPAWN_POINT = Vector2(630, 350)

@export_group("Vehicles", "veh_")
@export var veh_vehicle_speed := 100.0
@export var veh_vehicle_rotation := 2.0
@export_range(0, 10, 1) var veh_vehicle_parking_rotation := 5.0
@export var veh_current_vehicle: Game2Vehicle

@onready var parking_spaces: Game2ParkingSpacesController = $ParkingSpaces
@onready var vehicles: Node2D = $Vehicles
@onready var pause_menu: ColorRect = $Menu/Pause
@onready var game_over_menu: ColorRect = $Menu/GameOver
@onready var obstacles: Game2ObstacleController = $Obstacles
@onready var start_timer: Timer = $StartTimer
@onready var boom_sprites: AnimatedSprite2D = $BoomSprites

var movement_vec := Vector2.UP
var next_car: Game2Vehicle
var vehicle_thread: Thread
var finished_parkings: int = 0:
	set(num):
		if num != 0 && num % 5 == 0:
			obstacles._activate_random_vehicle()
		finished_parkings = num
var end_game := false:
	set(new_end_game):
		end_game = new_end_game
		if EXPLOSIONS && randf() > 0.9:
			boom_sprites.visible = true
			SoundEffectMaster._PLAY_BY_NAME("boom")
			boom_sprites.play("default")
		else:
			SoundEffectMaster._PLAY_BY_NAME("car2_stop")
		for car in obstacles.used_parking_spaces:
			car.game_speed = 0.0
		for car in obstacles.available_parking_spaces:
			car.game_speed = 0.0
		@warning_ignore("integer_division")
		GameMaster.instance.tin_cans += finished_parkings / 2
		@warning_ignore("integer_division")
		$Menu/GameOver/MarginContainer/VBoxContainer/VBoxContainer/CansLabel.text = can_label % (finished_parkings / 2)
		game_over_menu.visible = true
var paused := false:
	set(new_paused):
		paused = new_paused
		pause_menu.visible = paused
		if paused && !end_game:
			for car in obstacles.used_parking_spaces:
				car.game_speed = 0.1
			@warning_ignore("integer_division")
			$Menu/Pause/MarginContainer/VBoxContainer/CansLabel.text = can_label % (finished_parkings / 2)
		elif !end_game:
			for car in obstacles.used_parking_spaces:
				car.game_speed = 1.0
var can_label := "Collected %d tin cans"
var enable_movement := true
var resets := 0:
	set(x):
		if x >= 0:
			resets = x
			veh_vehicle_speed *= 1.2
			veh_vehicle_rotation *= 1.2
			for car in obstacles.used_parking_spaces:
				car.speed *= 1.1
var has_moved := false
var EXPLOSIONS = false

func _ready():
	veh_current_vehicle.active = true
	veh_current_vehicle._randomize_color()
	vehicle_thread = Thread.new()
	vehicle_thread.start(_thread_spawn_new_vehicle)
	parking_spaces._activate_random_lot()
	for child: Game2ParkingSpace in parking_spaces.get_children():
		child.player_inside.connect(_on_player_entering_parking)
	for child: Game2MovingVehicle in obstacles.available_parking_spaces:
		child.hit_other_vehicle_better.connect(_check_collision)
	_localize()

func _input(event: InputEvent):
	if event is InputEventKey && !end_game:
		var text = event.as_text_keycode()
		if text == "Escape" && event.is_pressed():
			paused = !paused
		if !paused && enable_movement:
			if text == "Right" || text == "Left":
				veh_current_vehicle.wheels.visible = event.is_pressed()
			if text == "Right":
				veh_current_vehicle._change_wheels(true)
			if text == "Left":
				veh_current_vehicle._change_wheels(false)

func _process(delta):
	if veh_current_vehicle != null:
		boom_sprites.position = veh_current_vehicle.position
	if !paused && !end_game && enable_movement:
		if Input.is_key_pressed(KEY_UP):
			veh_current_vehicle.position += movement_vec.rotated(veh_current_vehicle.rotation) * veh_vehicle_speed * delta
			_handle_rotation(delta)
		if Input.is_key_pressed(KEY_DOWN):
			veh_current_vehicle.position += movement_vec.rotated(veh_current_vehicle.rotation) * -veh_vehicle_speed * delta
			_handle_rotation(delta, true)

func _handle_rotation(delta: float, invert := false):
	has_moved = true
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
	car.rotation = -PI / 2
	vehicles.call_deferred("add_child", car)
	next_car = car

func _get_next_vehicle():
	finished_parkings += 1
	enable_movement = false
	has_moved = false
	start_timer.start()
	veh_current_vehicle.active = false
	veh_current_vehicle = next_car
	veh_current_vehicle.visible = true
	veh_current_vehicle.active = true
	veh_current_vehicle._randomize_color()
	veh_current_vehicle.hit_other_vehicle.connect(_check_collision)
	next_car = null
	if GameMaster.instance.threading_check:
		vehicle_thread.wait_to_finish()
		vehicle_thread = Thread.new()
		vehicle_thread.start(_thread_spawn_new_vehicle)
	else:
		_thread_spawn_new_vehicle()
	parking_spaces._activate_random_lot()
	if finished_parkings != 0 && finished_parkings % 2 == 0:
		SoundEffectMaster._PLAY_BY_NAME("game_can")
	start_timer.start()

func _on_player_entering_parking(type: Game2ParkingSpace.TYPE):
	if _check_player_position(type):
		_get_next_vehicle()

func _check_player_position(type: Game2ParkingSpace.TYPE) -> bool:
	var rotat = (rad_to_deg(veh_current_vehicle.rotation) as int) % 180
	print("Angle: ", abs(rotat))
	if type == Game2ParkingSpace.TYPE.Vertical:
		return (abs(rotat) < veh_vehicle_parking_rotation || abs(rotat) > 180 - veh_vehicle_parking_rotation)
	else:
		return (abs(rotat) < 90 + veh_vehicle_parking_rotation && abs(rotat) > 90 - veh_vehicle_parking_rotation)

func _reset_parking():
	for child: Game2Vehicle in vehicles.get_children():
		if child == veh_current_vehicle:
			continue
		child.queue_free()
	resets += 1

func _check_collision(area: Area2D, soldat := false):
	if area == veh_current_vehicle && has_moved:
		EXPLOSIONS = soldat
		end_game = true

func _unpause_button():
	paused = false

func _replay():
	@warning_ignore("integer_division")
	GameMaster.instance.tin_cans += finished_parkings / 2
	GameMaster.instance._change_current_scene(3)

func _return_to_game():
	@warning_ignore("integer_division")
	GameMaster.instance.tin_cans += finished_parkings / 2
	GameMaster.instance._change_current_scene(1)

func _enable_movement():
	enable_movement = true

func _localize():
	can_label = LocalizationMaster._GET_VALUE("cans_score_%s")
