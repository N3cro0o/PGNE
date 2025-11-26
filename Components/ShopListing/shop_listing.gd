class_name ShopListing extends ColorRect

@onready var image: TextureRect = $Box/Layout/Image
@onready var name_label: Label = $Box/Layout/Name
@onready var cost_label: Label = $Box/Layout/Cost
@onready var buy: Button = $Box/Layout/Buy

var debug_group_name: String
var debug_name: String
var cost: int
var tween_color: Tween
var is_drip := false
var toggle = false
var can_text = ""

func _ready() -> void:
	_on_resize()

func _load_data(data: ShopItem):
	await self.ready
	can_text = LocalizationMaster._GET_VALUE("tin_cans")
	cost_label.text = str(data.cost) + " %s" % can_text
	name_label.text = LocalizationMaster._GET_VALUE(data.debug_name)
	image.texture = data.image
	cost = data.cost
	debug_name = data.debug_name
	if data is ShopItemDrip:
		debug_group_name = data.debug_group_name

func _buy_click():
	if !buy.toggle_mode:
		if GameMaster.instance.tin_cans < cost:
			buy.self_modulate = Color.RED
			if tween_color != null:
				tween_color.kill()
			tween_color = get_tree().create_tween()
			tween_color.tween_property(buy, "self_modulate", Color.WHITE, 0.2)
			return
		GameMaster.instance.tin_cans -= cost
		if !is_drip:
			PlayerMaster.fridge[debug_name] += 1
		else:
			_toggle_to_toggle(true)
	if tween_color != null:
		tween_color.kill()
	buy.scale = Vector2.ONE * 1.1
	tween_color = get_tree().create_tween()
	tween_color.tween_property(buy, "scale", Vector2.ONE, 0.25)
	tween_color.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

func _toggle_to_toggle(on: bool):
	toggle = true
	buy.toggle_mode = true
	buy.button_pressed = on
	if on:
		buy.text = LocalizationMaster._GET_VALUE("yes")
		PlayerMaster.instance.wearing_items.set(debug_name, 2)
	else:
		buy.text = LocalizationMaster._GET_VALUE("no")
		PlayerMaster.instance.wearing_items.set(debug_name, 1)
	name_label.text = LocalizationMaster._GET_VALUE("wearing_label")
	buy.pressed.disconnect(_buy_click)

func _toggle_to_toggle_on():
	_toggle_to_toggle(true)

func _toggle_to_toggle_off():
	_toggle_to_toggle(false)

func _on_resize():
	if self.is_node_ready():
		buy.pivot_offset = buy.size / 2

func _drip_toggle(toggled_on: bool):
	var col = Color(0.8, 0.8, 0.8, 0.271)
	var val = 1
	if toggled_on:
		val = 2
		buy.text = LocalizationMaster._GET_VALUE("yes")
		# Turn all listings from the same group
		for listing: ShopListing in get_parent().get_children():
			if listing == self:
				continue
			if listing.is_drip && listing.debug_group_name == debug_group_name && listing.toggle:
				listing.buy.button_pressed = false
	else:
		col = Color(0.0, 0.0, 0.0, 0.271)
		buy.text = LocalizationMaster._GET_VALUE("no")
	PlayerMaster.instance._update_wardrobe(debug_name, val)
	await get_tree().process_frame
	if tween_color != null:
		tween_color.kill()
	tween_color = get_tree().create_tween()
	tween_color.tween_property(self, "color", col, 0.25)
