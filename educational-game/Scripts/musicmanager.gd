extends Node

var audio_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _init() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "Music"
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Master"


func _ready() -> void:
	add_child(audio_player)
	add_child(ambient_player)
	add_child(sfx_player)


func play_ambient(stream: AudioStream, volume_db: float = 0.0) -> void:
	if ambient_player == null or stream == null:
		return
	ambient_player.stream = stream
	ambient_player.volume_db = volume_db
	ambient_player.play()


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if sfx_player == null or stream == null:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()


func stop_ambient() -> void:
	if ambient_player == null:
		return
	ambient_player.stop()


func play(stream: AudioStream, volume_db: float = 0.0) -> void:
	if audio_player == null or stream == null:
		return
	if audio_player.stream == stream and audio_player.playing:
		return  # already playing this track, don't restart
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.play()


func stop() -> void:
	if audio_player == null:
		return
	audio_player.stop()


func set_volume(volume_db: float) -> void:
	if audio_player == null:
		return
	audio_player.volume_db = volume_db


func is_playing() -> bool:
	if audio_player == null:
		return false
	return audio_player.playing
