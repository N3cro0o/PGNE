class_name PolygonButton2D extends Polygon2D

@export var active = true:
	set(a):
		active = a
		if a:
			visible = true
		else:
			visible = false
@export var blocked = false

var broken = false:
	set(x):
		if x:
			modulate = Color.ORANGE_RED
		broken = x
var new_polygon: PackedVector2Array
var inside = false

signal pressed(instance: PolygonButton2D)

func _ready():
	new_polygon = polygon
	for i in new_polygon.size():
		var vec = new_polygon[i]
		new_polygon[i] = vec + position 

func _process(_delta):
	if blocked && active && !broken:
		modulate = Color.WHITE

func _input(event: InputEvent) -> void:
	if !blocked && active:
		if event is InputEventMouseMotion:
			if Geometry2D.is_point_in_polygon(event.position, new_polygon):
				#TODO Add toolbar logic
				if broken:
					modulate = Color.RED
				else:
					modulate = Color.YELLOW
				inside = true
			else:
				if broken:
					modulate = Color.ORANGE_RED
				else:
					modulate = Color.WHITE
				inside = false
		if event is InputEventMouseButton && event.is_pressed() && inside && visible && get_parent().visible:
			pressed.emit(self)
