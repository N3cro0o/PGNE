class_name MainMenu extends Control

#region Variables

@export var rotation_speed: Curve
@onready var bg: TextureRect = $BG

var t: float:
	set(x):
		if x > 1:
			t = 0
		else:
			t = x

var input_queue: Array[String] = []

#endregion

func _process(delta):
	t += delta / 10
	bg.rotation += rotation_speed.sample(t) * delta / 4
	
func _start_button_pressed():
	GameMaster.instance.in_game = true
	GameMaster.instance._change_current_scene(1)

func _hide_panels(event: InputEvent):
	if event is InputEventMouseButton && event.is_pressed():
		$SubMenuMargin/Options.visible = false

func _option_button_pressed():
	$SubMenuMargin/Options.visible = !$SubMenuMargin/Options.visible

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.is_pressed():
			input_queue.push_back(event.as_text_keycode())
			if input_queue.size() > 8:
				input_queue.pop_front()
			if input_queue == ["Up", "Up", "Down", "Down", "Left", 
				"Right", "Left", "Right"]:
				print("kretex")
				GameMaster.instance.tin_cans += 10
