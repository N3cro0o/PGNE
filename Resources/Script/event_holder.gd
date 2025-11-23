class_name EventHolder extends Resource

enum ROOM {
	AKADEMYK,
	SRACZ,
	JADLODALNIA,
	HOME_OFFICE
}

@export var debug_name: String
@export var debug_event_label_name: String
@export var which: ROOM
@export_range(0, 600, 1) var block_for: float = 60
