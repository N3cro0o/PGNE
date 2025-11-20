class_name MinigameMenus extends Control

signal return_press
signal unpause_press
signal retry_press

func _ready():
	_localize()

func on_return_button_press():
	return_press.emit()

func on_unpause_button_press():
	unpause_press.emit()

func on_retry_button_press():
	retry_press.emit()

func _localize():
	$Pause/MarginContainer/VBoxContainer/VBoxContainer/Label.text = LocalizationMaster._GET_VALUE("paused_label_1")
	$Pause/MarginContainer/VBoxContainer/VBoxContainer/Label2.text = LocalizationMaster._GET_VALUE("paused_label_2")
	$GameOver/MarginContainer/VBoxContainer/VBoxContainer/Label.text = LocalizationMaster._GET_VALUE("gameover_label_1")
	var bttn_text = $Pause/MarginContainer/VBoxContainer/Unpause.text
	$Pause/MarginContainer/VBoxContainer/Unpause.text = LocalizationMaster._GET_VALUE(bttn_text)
	bttn_text = $Pause/MarginContainer/VBoxContainer/ReturnToMainGame.text
	$Pause/MarginContainer/VBoxContainer/ReturnToMainGame.text = LocalizationMaster._GET_VALUE(bttn_text)
	$GameOver/MarginContainer/VBoxContainer/ReturnToMainGame.text = LocalizationMaster._GET_VALUE(bttn_text)
	bttn_text = $GameOver/MarginContainer/VBoxContainer/Replay.text
	$GameOver/MarginContainer/VBoxContainer/Replay.text = LocalizationMaster._GET_VALUE(bttn_text)
