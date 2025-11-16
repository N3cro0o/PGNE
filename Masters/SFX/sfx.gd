class_name SoundEffectMaster extends Node2D

static var instance: SoundEffectMaster

enum SoundEnum {
	UI,
	Audio,
	Music
}
static var MASTER_BUS_ID := AudioServer.get_bus_index("Master")
static var SOUNDS_BUS_ID := AudioServer.get_bus_index("Sounds")
static var MUSIC_BUS_ID := AudioServer.get_bus_index("Music")

@export var sounds_array: Array[SoundHolder]
@export var music_array: Array[MusicHolder]

@onready var sounds_player: AudioStreamPlayer = $Sounds
@onready var music_player: AudioStreamPlayer = $Music

var current_music: MusicHolder

static func _PLAY_MUSIC_BY_NAME(music_name: String):
	SoundEffectMaster.instance._play_music_by_name(music_name)

static func _PLAY_BY_ID(sound_id: int):
	SoundEffectMaster.instance._play_sound_by_id(sound_id)
	
static func _PLAY_BY_NAME(sound_name: String):
	SoundEffectMaster.instance._play_sound_by_name(sound_name)

static func _STOP_SOUNDS():
	SoundEffectMaster.instance._stop_all_sounds()

func _ready():
	instance = self
	
func _process(_delta: float) -> void:
	if music_player.playing:
		var time = music_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		if time >= current_music.loop_points[current_music.which_loop].y && current_music.loop:
			music_player.seek(current_music.loop_points[current_music.which_loop].x)

func _play_sound_by_id(num: int):
	if !_play(sounds_array[num], SoundEnum.Audio):
		push_error("_play_sound_by_id() wrong num")

func _play_sound_by_name(text: String):
	for s in sounds_array:
		if s.name == text:
			_play(s, SoundEnum.Audio)
			return
	push_error("play_sound_by_name() wrong sound_name")

func _stop_all_sounds():
	$Sounds.stop()

func _play(sound: SoundHolder, what: SoundEnum = SoundEnum.Audio) -> bool:
	if sound == null:
		push_error("SoundHolder is null")
		return false
	match what:
		SoundEnum.Music:
			sound = sound as MusicHolder
			if sound == current_music:
				return true
			music_player.stream = sound.stream
			var offset = 0.0
			if sound.loop && !sound.start_from_start:
				offset = sound.loop_points[sound.which_loop].x
			current_music = sound
			music_player.play(offset)
		SoundEnum.Audio:
			sounds_player.stream = sound.stream
			sounds_player.volume_db = sound.volume
			sounds_player.play()
	return true

func _play_music_by_name(music_name: String):
	var music = _find_music_by_name(music_name)
	if !_play(music, SoundEnum.Music):
		push_error("_play_music_by_name() wrong music_name")

func _find_music_by_name(music_name: String) -> MusicHolder:
	for s in music_array:
		if s.name == music_name:
			return s
	return null
