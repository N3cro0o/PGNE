class_name SoundEffectMaster extends Node2D

static var instance: SoundEffectMaster

enum SoundEnum {
	UI,
	Audio,
	Music
}

@export var sounds_array: Array[SoundHolder]
@export var music_array: Array[MusicHolder]

@onready var sounds_player: AudioStreamPlayer = $Sounds
@onready var music_player: AudioStreamPlayer = $Music
@onready var master_bus := AudioServer.get_bus_index("Master")
@onready var sounds_bus := AudioServer.get_bus_index("Sounds")
@onready var music_bus := AudioServer.get_bus_index("Music")

static func _PLAY_BY_ID(sound_id: int):
	SoundEffectMaster.instance._play_sound_by_id(sound_id)
	
static func _PLAY_BY_NAME(sound_name: String):
	SoundEffectMaster.instance.play_sound_by_name(sound_name)

func _ready():
	instance = self

func _play_sound_by_id(num: int):
	_play(sounds_array[num], SoundEnum.UI)

func play_sound_by_name(text: String):
	for s in sounds_array:
		if s.name == text:
			_play(s, SoundEnum.Audio)
			break

func _play(sound: SoundHolder, what: SoundEnum = SoundEnum.Audio):
	if sound == null:
		return
	match what:
		SoundEnum.Music:
			sound = sound as MusicHolder
			#if sound == music_data:
				#return
			#music_bus.stream = sound.stream
			#var offset = 0.0
			#if sound.loop && !sound.start_from_start:
				#offset = sound.loop_points[sound.which_loop].x
			#music_data = sound
			#music_bus.play(offset)
		SoundEnum.Audio:
			sounds_player.stream = sound.stream
			sounds_player.volume_db = sound.volume
			sounds_player.play()
