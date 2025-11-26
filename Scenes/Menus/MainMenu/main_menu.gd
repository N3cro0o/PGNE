class_name MainMenu extends Control

#region Variables

@export var rotation_speed: Curve
@onready var bg: TextureRect = $BG

@onready var master_slider: HSlider = $SubMenuMargin/Options/VBoxContainer/MasterSlider/HSlider
@onready var sounds_slider: HSlider = $SubMenuMargin/Options/VBoxContainer/SoundsSlider/HSlider
@onready var music_slider: HSlider = $SubMenuMargin/Options/VBoxContainer/MusicSlider/HSlider
@onready var save_button: Button = $SubMenuMargin/Options/VBoxContainer/HBoxContainer/SaveButton
@onready var language_section: OptionButton = $SubMenuMargin/Options/VBoxContainer/LanguageSelect
@onready var mobile_ui_toggle: CheckButton = $SubMenuMargin/Options/VBoxContainer/MobileUI
@onready var reset_button: Button = $SubMenuMargin/Options/VBoxContainer/HBoxContainer/ResetButton

var t: float:
	set(x):
		if x > 1:
			t = 0
		else:
			t = x

var input_queue: Array[String] = []

#endregion

func _ready():
	var data := OptionsAndSaveManager.instance.data
	master_slider.value = data.master
	sounds_slider.value = data.sounds
	music_slider.value = data.music
	mobile_ui_toggle.button_pressed = data.mobile_toggle
	SoundEffectMaster._PLAY_MUSIC_BY_NAME("main_theme")
	# Create locals items
	for local in LocalizationMaster.LOCAL.values():
		var sufix = LocalizationMaster.LOCALIATION_NAMES[local]
		language_section.add_item(LocalizationMaster._GET_VALUE("lang_%s" % sufix))
	language_section.select(data.localization)
	_localize()

func _process(delta):
	t += delta / 10
	bg.rotation += rotation_speed.sample(t) * delta / 4
	
func _start_button_pressed():
	_save_request()
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
				GameMaster.instance.tin_cans += 69

func _master_slider(value: float):
	print("Master: ", linear_to_db(value))
	OptionsAndSaveManager.instance.data._update_master_value(value)

func _sounds_slider(value: float):
	print("Sounds: ", linear_to_db(value))
	OptionsAndSaveManager.instance.data._update_sounds_value(value)

func _music_slider(value: float):
	print("Music: ", linear_to_db(value))
	OptionsAndSaveManager.instance.data._update_music_value(value)

func _save_request():
	print("Save")
	OptionsAndSaveManager._SAVE()

func _select_lang(id: int):
	#var lang = OptionsAndSaveManager.LOCAL.keys()[id]
	#print(lang)
	#print(OptionsAndSaveManager.LOCAL[lang])
	OptionsAndSaveManager.instance.data.localization = id as LocalizationMaster.LOCAL
	LocalizationMaster.instance._load_localization(id as LocalizationMaster.LOCAL)
	_localize()

func _mobile_toggle(value: bool):
	OptionsAndSaveManager.instance.data.mobile_toggle = value

func _reset_button():
	OptionsAndSaveManager.instance._reset_all()

func _localize():
	$ButtonsMargin/BttnMargin/BttnContainer/Start.text = LocalizationMaster._GET_VALUE("start")
	$ButtonsMargin/BttnMargin/BttnContainer/Options.text = LocalizationMaster._GET_VALUE("options")
	$ButtonsMargin/BttnMargin/BttnContainer/Saves.text = LocalizationMaster._GET_VALUE("change_save")
	$SubMenuMargin/Options/VBoxContainer/MasterSlider/Label.text = LocalizationMaster._GET_VALUE("master_bus")
	$SubMenuMargin/Options/VBoxContainer/SoundsSlider/Label.text = LocalizationMaster._GET_VALUE("sounds_bus")
	$SubMenuMargin/Options/VBoxContainer/MusicSlider/Label.text = LocalizationMaster._GET_VALUE("music_bus")
	reset_button.text = LocalizationMaster._GET_VALUE("reset_options")
	mobile_ui_toggle.text = LocalizationMaster._GET_VALUE("mobile_toggle")
	save_button.text = LocalizationMaster._GET_VALUE("manual_save")
	for i in language_section.item_count:
		var sufix = LocalizationMaster.LOCALIATION_NAMES[i as LocalizationMaster.LOCAL]
		language_section.set_item_text(i, LocalizationMaster._GET_VALUE("lang_%s" % sufix))
