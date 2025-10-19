class_name MainGameUI extends Control

#region Variables

@onready var hp_label: Label = $UI/Top/TopMargin/HBox/HPLabel
@onready var hunger_label: Label = $UI/Top/TopMargin/HBox/HungriLabel
@onready var bladder_label: Label = $UI/Top/TopMargin/HBox/BladderLabel
@onready var fun_label: Label = $UI/Top/TopMargin/HBox/FunLabel

signal OnQuitPress
signal OnAkademykPress
signal OnSraczPress
signal OnJadlodalniaPress
signal OnHomeOfficePress

#endregion

func _process(_delta: float) -> void:
	hp_label.text = "Sleep: %d" % PlayerMaster.instance.health
	hunger_label.text = "Hunger: %d" % PlayerMaster.instance.hunger
	bladder_label.text = "Bladder: %d" % PlayerMaster.instance.bladder
	fun_label.text = "Fun: %d" % PlayerMaster.instance.stress

#region Room Buttons

func _quit_press():
	OnQuitPress.emit()

func _akademyk_press():
	OnAkademykPress.emit()

func _sracz_press():
	OnSraczPress.emit()

func _jadlodalnia_press():
	OnJadlodalniaPress.emit()

func _home_office_press():
	OnHomeOfficePress.emit()

#endregion
