extends Node


onready var title_theme: AudioStreamOGGVorbis = preload("res://music/title.ogg")
onready var map_theme: AudioStreamOGGVorbis = preload("res://music/overworld.ogg")
onready var battle_theme: AudioStreamOGGVorbis = preload("res://music/battle.ogg")
onready var final_boss_theme: AudioStreamOGGVorbis = preload("res://music/final_boss.ogg")

var current_player: AudioStreamPlayer = null

func play_theme(theme_name: String):
	
	var tween = Tween.new()
	
	if current_player != null:
		current_player.call_deferred("free")
	
	
	var theme_player = AudioStreamPlayer.new()
	add_child(theme_player)
	
	current_player = theme_player
	
	var theme_to_play: AudioStreamOGGVorbis
	
	match theme_name:
		"Title":
			theme_to_play = title_theme
		
		"Map":
			theme_to_play = map_theme
		
		"Battle":
			theme_to_play = battle_theme
		
		"FinalBoss":
			theme_to_play = final_boss_theme
	
	theme_player.stream = theme_to_play
	theme_player.bus = "BGM"
	theme_player.play()
