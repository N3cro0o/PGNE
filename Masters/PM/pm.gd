class_name PlayerMaster extends Node2D

static var instance: PlayerMaster
#TODO Add piwko count... somewhere
static var fridge := {
	"bread": 3,
	"piwko": 2,
	"hotdog": 0,
	"pizza": 1,
	"burtella": 0
}:
	set(new_fridge):
		fridge = new_fridge
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().fridge = new_fridge

#region Variables

@export var force_start := false
@export_category("Stats")
@export var max_health: float = 100
@export var max_hunger: float = 100
@export var max_bladder: float = 100
@export var max_stress: float = 100
@export_category("Multiplier")
@export var health_multi: float = 0.8
@export var hunger_multi: float = 1
@export var bladder_multi: float = 1.2
@export var stress_multi: float = 1

var health: float = 100:
	set(hp):
		if hp < 0:
			health = 0
		elif hp > max_health:
			health = max_health
		else:
			health = hp
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().health = health
var hunger: float = 100:
	set(hg):
		if hg < 0:
			hunger = 0
		elif hg > max_hunger:
			hunger = max_hunger
		else:
			hunger = hg
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().hunger = hunger
var bladder: float = 100:
	set(bl):
		if bl < 0:
			bladder = 0
		elif bl > max_bladder:
			bladder = max_bladder
		else:
			bladder = bl
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().bladder = bladder
var stress: float = 100:
	set(sr):
		if sr < 0:
			stress = 0
		elif sr > max_stress:
			stress = max_stress
		else:
			stress = sr
		OptionsAndSaveManager._RETURN_CURR_SAVEDATA().stress = stress

#endregion

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	if force_start || GameMaster.instance.in_game:
		health -= health_multi * delta
		hunger -= hunger_multi * delta
		bladder -= bladder_multi * delta
		stress -= stress_multi * delta
