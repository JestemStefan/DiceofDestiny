extends Node

onready var cheater_sound: AudioStreamOGGVorbis = preload("res://sfx/CheaterSound.ogg")
# Cheat code
var sequence = [
	KEY_I,
	KEY_R,
	KEY_O,
	KEY_L,
	KEY_L,
	KEY_2,
	KEY_0]
	
var sequence_index = 0

func _input(event):
	cheat_code(event)

func cheat_code(event):
	if event is InputEventKey and event.pressed:
		print(event.scancode)
		if event.scancode == sequence[sequence_index]:
			sequence_index += 1
			if sequence_index == sequence.size():
				if GameState.isCheater:
					GameState.deavtivate_cheats()
				else:
					GameState.activate_cheats()
					
				print("Cheat code: " + str(GameState.isCheater))
				
				AudioManager.play_sfx(cheater_sound)
				
				sequence_index = 0
		else:
			sequence_index = 0
	
