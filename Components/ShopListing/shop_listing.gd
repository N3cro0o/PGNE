class_name ShopListing extends ColorRect

@onready var image: TextureRect = $Box/Layout/Image
@onready var name_label: Label = $Box/Layout/Name
@onready var cost_label: Label = $Box/Layout/Cost
@onready var buy: Button = $Box/Layout/Buy

var cost: int
var tween_color: Tween

func _load_data(data: ShopItem):
	await self.ready
	cost_label.text = str(data.cost) + " Cans"
	name_label.text = str(data.name)
	image.texture = data.image
	cost = data.cost

func _buy_click():
	if GameMaster.instance.tin_cans < cost:
		buy.self_modulate = Color.RED
		if tween_color != null:
			tween_color.kill()
		tween_color = get_tree().create_tween()
		tween_color.tween_property(buy, "self_modulate", Color.WHITE, 0.2)
		return
