extends Node


onready var title_theme: AudioStreamOGGVorbis = preload("res://music/title.ogg")
onready var map_theme: AudioStreamOGGVorbis = preload("res://music/overworld.ogg")
onready var battle_theme: AudioStreamOGGVorbis = preload("res://music/battle.ogg")
onready var boss_theme: AudioStreamOGGVorbis = preload("res://music/lich.ogg")
onready var final_boss_theme: AudioStreamOGGVorbis = preload("res://music/final_boss.ogg")
onready var epilogue_theme: AudioStreamOGGVorbis = preload("res://music/epilogue2.ogg")

var current_player: AudioStreamPlayer = null

var last_map_theme_position: float = 0

func play_theme(theme_name: String, should_loop: bool = true):
	
	#var tween = Tween.new()
	
	if current_player != null:
		if current_player.stream == map_theme:
			last_map_theme_position = current_player.get_playback_position()

		current_player.call_deferred("free")
	
	
	var theme_player = AudioStreamPlayer.new()
	add_child(theme_player)
	
	current_player = theme_player
	
	var theme_to_play: AudioStreamOGGVorbis
	var start_from: float = 0
	
	match theme_name:
		"Title":
			theme_to_play = title_theme
		
		"Map":
			theme_to_play = map_theme
			start_from = last_map_theme_position
		
		"Battle":
			theme_to_play = battle_theme
			
		"Boss":
			theme_to_play = boss_theme
		
		"FinalBoss":
			theme_to_play = final_boss_theme
		
		"Epilogue":
			theme_to_play = epilogue_theme
		
	
	theme_player.stream = theme_to_play
	theme_player.stream.set_loop(should_loop)
	
	theme_player.bus = "BGM"
	
	theme_player.play(start_from)


func play_sfx(sfx_sound: AudioStreamOGGVorbis, should_loop: bool = false):
	
	# create new audio player and spawn it
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	# connect signal that will be emitted when sound finished playing
	sfx_player.connect("finished", self, "_on_sfx_ended", [sfx_player])
	
	# assign selected sound to player and apply options
	sfx_player.set_bus("SFX") 				# assign audio bus
	sfx_player.stream = sfx_sound			# assign sound that will be played
	sfx_player.stream.set_loop(should_loop)	# enable or diable looping
	
	# play sound
	sfx_player.play()


func _on_sfx_ended(audio_player: AudioStreamPlayer):
	
	# if sfx should loop then play again
	if audio_player.stream.has_loop():
		audio_player.play(0.0)
	
	# if not then delete audioplayer
	else:
		audio_player.call_deferred("free")
