extends Node2D

#region Variables
#region Exports

@export var bg_speed = 100.0
@export_group("Obstacles", "obs_")
@export_range(0, 300, 1) var obs_stop_thresh = 200.0
@export var obs_left: Array[Game1Obstacle]
@export var obs_right: Array[Game1Obstacle]
@export var obs_cars: Array[Game1Obstacle]
@export var tin_cans: Array[TinCans]
@export_group("Difficulty", "dif_")
@export var dif_speed = 1.0
@export_range(15.0, 45.0, 0.1) var dif_time_offset = 15.0
@export_range(0, 5) var dif_timer_speed = 1.0
@export_range(1, 5) var dif_can_spawn_offset = 1.0
@onready var main_character: Node2D = $MainCharacter
@onready var lines: Array[Line2D] = [$Lines/Opposite, $Lines/Left, $Lines/Right]
@onready var stop_obstacles: Area2D = $StopObstacles
@onready var timer_left: Timer = $TimerLeft

#endregion

@onready var pause_menu: ColorRect = $Menu/Pause
@onready var game_over_menu: ColorRect = $Menu/GameOver
@onready var background_sprites = [$BGS/BG, $BGS/BG2, $BGS/BG3]

var collected_cans = 0
var player_pos = 0:
	set(i):
		if abs(i) <= 1:
			player_pos = i
var player_tween: Tween
var time_in_game := 0.0
var difficulty := 1.0
var left_index = 0:
	set(ind):
		if ind >= obs_left.size():
			left_index = 0
		else:
			left_index = ind
var right_index = 0:
	set(ind):
		if ind >= obs_right.size():
			right_index = 0
		else:
			right_index = ind
var can_index = 0:
	set(ind):
		if ind >= tin_cans.size():
			can_index = 0
		else:
			can_index = ind
var can_offset = 0.0
var end_game := false:
	set(new_end_game):
		end_game = new_end_game
		game_speed = 0.0
		difficulty = 0
		player_tween.kill()
		$Obstacles/ObstacleCar1/AnimatedSprite2D.stop()
		$Obstacles/ObstacleCar1/Shadow.stop()
		$MainCharacter/Main.stop()
		$MainCharacter/Shadow.stop()
		$Menu/GameOver/MarginContainer/VBoxContainer/VBoxContainer/CansLabel.text = can_label % collected_cans
		game_over_menu.visible = true
		SoundEffectMaster._STOP_SOUNDS()
var paused := false:
	set(new_paused):
		paused = new_paused
		pause_menu.visible = paused
		if paused && !end_game:
			game_speed = 0.05
			$Menu/Pause/MarginContainer/VBoxContainer/CansLabel.text = can_label % collected_cans
		elif !end_game:
			game_speed = 1.0
var game_speed := 1.0
var can_label := "Collected %d tin cans"

#endregion

func _ready():
	player_pos = 0
	time_in_game = 0
	_update_player_pos(true)
	var coll_shape = stop_obstacles.get_child(0).shape as WorldBoundaryShape2D
	coll_shape.distance = -obs_stop_thresh * game_speed
	timer_left.start(dif_timer_speed)
	_localize()

func _physics_process(delta):
	time_in_game += delta * game_speed
	if time_in_game > dif_time_offset:
		difficulty = exp((time_in_game - dif_time_offset) / 30) * dif_speed
	_update_obstacles()

func _process(delta: float) -> void:
	for bg in background_sprites:
		bg.position.x -= bg_speed * delta * difficulty * game_speed
		if bg.position.x < -340.0:
			bg.position.x = 910.0

func _input(event: InputEvent):
	if event is InputEventKey && event.is_pressed() && !end_game:
		if event.as_text_keycode() == "Escape" && !end_game:
			paused = !paused
		if event.as_text_keycode() == "Up" && !paused:
			player_pos -= 1
			SoundEffectMaster._PLAY_BY_NAME("car1_move")
			_update_player_pos()
		elif event.as_text_keycode() == "Down" && !paused:
			player_pos += 1
			SoundEffectMaster._PLAY_BY_NAME("car1_move")
			_update_player_pos()

func _get_next_obstacle(left: bool = true) -> Game1Obstacle:
	if left:
		for _i in obs_left.size():
			if !obs_left[left_index].active:
				return obs_left[left_index]
			left_index += 1
	else:
		for _i in obs_right.size():
			if !obs_right[right_index].active:
				return obs_right[right_index]
			right_index += 1
	return null

func _get_next_can() -> TinCans:
	for _i in tin_cans.size():
		if !tin_cans[can_index].active:
			return tin_cans[can_index]
		can_index += 1
	return null

func _update_obstacles():
	for obs in obs_left:
		obs.real_move_speed = obs.move_speed * difficulty * game_speed
	for obs in obs_right:
		obs.real_move_speed = obs.move_speed * difficulty * game_speed
	$Obstacles/ObstacleCar1.real_move_speed = $Obstacles/ObstacleCar1.move_speed * sqrt(difficulty) * game_speed
	for can in tin_cans:
		can.real_move_speed = can.move_speed * game_speed

func _obstacle_hit(area: Area2D):
	if area.is_in_group("player"):
		end_game = true

func _can_signal(value: int):
	SoundEffectMaster._PLAY_BY_NAME("game_can")
	collected_cans += value

func _reset_obstacle(area: Area2D):
	if area is Game1Obstacle:
		area._reset()

func _on_obstacle_timer():
	if !(paused || end_game):
		var rand = randf()
		var can = randf()
		if rand < 0.50:
			_obstacle_handle(_get_next_obstacle(true))
			_can_handle(can, 1)
		else:
			_obstacle_handle(_get_next_obstacle(false))
			_can_handle(can, 2)
		if can * 4 > 2.81: # Instead of rolling new number, we can use can value. Since it's ready and ya know...
			can = randf()
			var car := $Obstacles/ObstacleCar1
			if !car.active:
				car.active = true
			_can_handle(can, 0)
	timer_left.wait_time = max(dif_timer_speed / sqrt(difficulty), 0.33)

func _obstacle_handle(obstacle: Game1Obstacle):
	if obstacle != null:
		obstacle.active = true

func _can_handle(prob: float, pos: int):
	if time_in_game < can_offset:
		return
	if prob > 0.95:
		var can = _get_next_can()
		pos -= 1
		if pos < 0:
			pos = 2
		if can != null:
			can.position.y = lines[pos].position.y
			can.active = true
	elif prob > 0.90:
		var can = _get_next_can()
		pos -= 1
		if pos < 0:
			pos = 2
		if can != null:
			can.position.y = lines[pos].position.y
			can.active = true
	can_offset = time_in_game + dif_can_spawn_offset

func _update_player_pos(instant := false):
	var pos_y = lines[player_pos + 1].position.y
	var player_fract = abs(pos_y - main_character.position.y) / (lines[2].position.y - lines[1].position.y)
	if player_tween != null:
		player_tween.kill()
	if !instant:
		player_tween = get_tree().create_tween()
		player_tween.tween_property(main_character, "position:y", pos_y, 0.4 * player_fract)
		player_tween.finished.connect(func(): SoundEffectMaster._STOP_SOUNDS())
	else:
		main_character.position.y = pos_y
	
func _unpause_button():
	paused = false

func _replay():
	GameMaster.instance._change_current_scene(2)

func _return_to_game():
	GameMaster.instance._change_current_scene(1)

func _localize():
	can_label = LocalizationMaster._GET_VALUE("cans_score_%s")
