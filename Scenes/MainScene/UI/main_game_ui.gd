class_name MainGameUI extends Control

#TODO https://forum.godotengine.org/t/how-do-i-create-a-scroller-that-scrolls-text/21721

#region Variables

const SHOP_LISTING = preload("uid://dejmqxbeg2e2s")

@export var event_label_speed = 350.0

@onready var hp_label: Label = $UI/Top/TopMargin/HBox/HPLabel
@onready var hunger_label: Label = $UI/Top/TopMargin/HBox/HungriLabel
@onready var bladder_label: Label = $UI/Top/TopMargin/HBox/BladderLabel
@onready var fun_label: Label = $UI/Top/TopMargin/HBox/FunLabel
@onready var cans_label: Label = $UI/Top/TopMargin/HBox/CansLabel
@onready var ui: VBoxContainer = $UI
@onready var shop: ColorRect = $Shop
@onready var gaming_menu: ColorRect = $GamingMenu
@onready var event_label: Label = $UI/Main/Blud/EventText/Label

@onready var box_for_shop_listings: VBoxContainer = $Shop/Margin/Body/ShopTabs/Food/Box
@onready var box_for_drip_listings: VBoxContainer = $Shop/Margin/Body/ShopTabs/Drip/Box

var health_label_text
var hunger_label_text
var stress_label_text
var bladder_label_text
var tin_cans_text

signal OnQuitPress
signal OnAkademykPress
signal OnSraczPress
signal OnJadlodalniaPress
signal OnHomeOfficePress

signal on_shop_close
signal on_game_center_close
signal on_game_start(id: int)

#endregion

func _ready() -> void:
	for item in GameMaster.instance.shop_items:
		if item.ignore:
			continue
		var listing = SHOP_LISTING.instantiate() as ShopListing
		listing._load_data(item)
		box_for_shop_listings.add_child(listing)
	for item in GameMaster.instance.shop_drip_items:
		if item.ignore:
			continue
		var listing = SHOP_LISTING.instantiate() as ShopListing
		listing._load_data(item)
		listing.is_drip = true
		if PlayerMaster.instance.wearing_items.get(item.debug_name) == 1:
			listing.call_deferred("_toggle_to_toggle_off")
		elif PlayerMaster.instance.wearing_items.get(item.debug_name) == 2:
			listing.call_deferred("_toggle_to_toggle_on")
		box_for_drip_listings.add_child(listing)
	_update_event_label()
	_localize()

func _process(_delta: float) -> void:
	hp_label.text = "%s: %d" % [health_label_text, PlayerMaster.instance.health]
	hunger_label.text = "%s: %d" % [hunger_label_text, PlayerMaster.instance.hunger]
	bladder_label.text = "%s: %d" % [bladder_label_text, PlayerMaster.instance.bladder]
	fun_label.text = "%s: %d" % [stress_label_text, PlayerMaster.instance.stress]
	cans_label.text = "%d %s" % [GameMaster.instance.tin_cans, tin_cans_text]
	event_label.position.x -= event_label_speed * _delta
	if event_label.position.x < -event_label.size.x:
		event_label.position.x = event_label.size.x

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

func _update_wait_panel(time: float):
	if time > 0:
		$UI/Main/Blud/ColorRect.visible = true
		var mins = int(time / 60)
		var secs = time - mins * 60
		$UI/Main/Blud/ColorRect/Box/Time.text = "%02d:%02d" % [mins, secs]
	else:
		$UI/Main/Blud/ColorRect.visible = false

func shop_enter():
	ui.visible = false
	shop.visible = true
	gaming_menu.visible = false

func shop_quit():
	ui.visible = true
	shop.visible = false
	gaming_menu.visible = false
	on_shop_close.emit()

func game_center_enter():
	ui.visible = false
	gaming_menu.visible = true
	shop.visible = false

func game_center_quit():
	ui.visible = true
	gaming_menu.visible = false
	shop.visible = false
	on_game_center_close.emit()

func game_button_press(id: int):
	on_game_start.emit(id)

func _update_event_label(debug_label: String = "", show_label := false):
	event_label.text = "%200s" % LocalizationMaster._GET_VALUE(debug_label)
	event_label.position.x = 0
	event_label.visible = show_label

func _localize():
	health_label_text = LocalizationMaster._GET_VALUE("health_label")
	hunger_label_text = LocalizationMaster._GET_VALUE("hunger_label")
	bladder_label_text = LocalizationMaster._GET_VALUE("bladder_label")
	stress_label_text = LocalizationMaster._GET_VALUE("stress_label")
	tin_cans_text = LocalizationMaster._GET_VALUE("tin_cans")
	$UI/Main/ColorRect/MainMargin/VBox/AkademykBttn.text = LocalizationMaster._GET_VALUE("akademyk")
	$UI/Main/ColorRect/MainMargin/VBox/SraczBttn.text = LocalizationMaster._GET_VALUE("bathroom")
	$UI/Main/ColorRect/MainMargin/VBox/Jadlobttn.text = LocalizationMaster._GET_VALUE("dinner")
	$UI/Main/ColorRect/MainMargin/VBox/HomeOfficeBttn.text = LocalizationMaster._GET_VALUE("home_office")
	$Shop/Margin/Body/Label.text = LocalizationMaster._GET_VALUE("shop")
	$GamingMenu/Margin/Body/Label.text = LocalizationMaster._GET_VALUE("game_center")
	$UI/Main/Blud/ColorRect/Box/Label.text = LocalizationMaster._GET_VALUE("wait_label")
	var game_bttn_text = $GamingMenu/Margin/Body/Games/MissAHole/Button.text
	$GamingMenu/Margin/Body/Games/MissAHole/Button.text = LocalizationMaster._GET_VALUE(game_bttn_text)
	game_bttn_text = $GamingMenu/Margin/Body/Games/PasatParking/Button.text
	$GamingMenu/Margin/Body/Games/PasatParking/Button.text = LocalizationMaster._GET_VALUE(game_bttn_text)
