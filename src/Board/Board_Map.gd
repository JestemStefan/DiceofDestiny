extends Node2D
class_name BoardMap

var board_tiles: Array

onready var sfx_rest_1: AudioStreamOGGVorbis = preload("res://sfx/GWJ_Rest3.1.ogg")
onready var sfx_move_1: AudioStreamOGGVorbis = preload("res://sfx/GWJ_DiceSlides-002.ogg")


# Called when the node enters the scene tree for the first time.
func _ready():
	board_tiles = $Board_Tiles.get_children()
	GameController.all_tiles = board_tiles
	GameController.current_board = self


func cover(on_off: bool):
	$MapOverlay.visible = on_off


func play_move_sound():
	AudioManager.play_sfx(sfx_move_1)
	

func play_rest_sound():
	AudioManager.play_sfx(sfx_rest_1)
