extends Node

var audio_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Music"  # optional, use "Master" if no bus set up
	add_child(audio_player)
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"
	add_child(sfx_player)

func play_ambient(stream: AudioStream, volume_db: float = 0.0):
	ambient_player.stream = stream
	ambient_player.volume_db = volume_db
	ambient_player.play()
	
func play_sfx(stream: AudioStream, volume_db: float = 0.0):
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()
	
func stop_ambient():
	ambient_player.stop()

func play(stream: AudioStream, volume_db: float = 0.0):
	if audio_player.stream == stream and audio_player.playing:
		return  # already playing this track, don't restart
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.play()

func stop():
	audio_player.stop()

func set_volume(volume_db: float):
	audio_player.volume_db = volume_db

func is_playing() -> bool:
	return audio_player.playing
