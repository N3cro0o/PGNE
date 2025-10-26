class_name MainGameUI extends Control

#region Variables

const SHOP_LISTING = preload("uid://dejmqxbeg2e2s")

@onready var hp_label: Label = $UI/Top/TopMargin/HBox/HPLabel
@onready var hunger_label: Label = $UI/Top/TopMargin/HBox/HungriLabel
@onready var bladder_label: Label = $UI/Top/TopMargin/HBox/BladderLabel
@onready var fun_label: Label = $UI/Top/TopMargin/HBox/FunLabel
@onready var cans_label: Label = $UI/Top/TopMargin/HBox/CansLabel
@onready var ui: VBoxContainer = $UI
@onready var shop: ColorRect = $Shop
@onready var gaming_menu: ColorRect = $GamingMenu

@onready var box_for_shop_listings: VBoxContainer = $Shop/Margin/Body/ShopTabs/Food/Box

signal OnQuitPress
signal OnAkademykPress
signal OnSraczPress
signal OnJadlodalniaPress
signal OnHomeOfficePress

signal on_shop_close
signal on_game_center_close

#endregion

func _ready() -> void:
	for item in GameMaster.instance.shop_items:
		if item.ignore:
			continue
		var listing = SHOP_LISTING.instantiate() as ShopListing
		listing._load_data(item)
		box_for_shop_listings.add_child(listing)

func _process(_delta: float) -> void:
	hp_label.text = "Sleep: %d" % PlayerMaster.instance.health
	hunger_label.text = "Hunger: %d" % PlayerMaster.instance.hunger
	bladder_label.text = "Bladder: %d" % PlayerMaster.instance.bladder
	fun_label.text = "Fun: %d" % PlayerMaster.instance.stress
	cans_label.text = "%d Cans" % GameMaster.instance.tin_cans

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
