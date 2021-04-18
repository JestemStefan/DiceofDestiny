extends CanvasLayer

func _ready():
	GameController.board_layer = self
	AudioManager.play_theme("Map")

