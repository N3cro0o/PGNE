class_name MinigameMenus extends Control

signal return_press
signal unpause_press
signal retry_press

func on_return_button_press():
	return_press.emit()

func on_unpause_button_press():
	unpause_press.emit()

func on_retry_button_press():
	retry_press.emit()
