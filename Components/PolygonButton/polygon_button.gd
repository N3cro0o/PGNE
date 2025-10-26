class_name PolygonButton2D extends Polygon2D

var new_polygon: PackedVector2Array
var inside = false
signal pressed

func _ready():
	new_polygon = polygon
	for i in new_polygon.size():
		var vec = new_polygon[i]
		new_polygon[i] = vec + position 


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Geometry2D.is_point_in_polygon(event.position, new_polygon):
			#TODO Add toolbar logic
			modulate = Color.YELLOW
			inside = true
		else:
			modulate = Color.WHITE
			inside = false
	if event is InputEventMouseButton && event.is_pressed() && inside && visible && get_parent().visible:
		print("Click!")
		pressed.emit()
