extends Node2D

onready var dice_instance: PackedScene = preload("res://scenes/Dice/Test_Dice.tscn")

onready var sfx_diceroll: AudioStreamOGGVorbis = preload("res://sfx/GWJ32_DiceRollLong_3.ogg")

onready var dice_positions: Array = [$Dice1, $Dice2, $Dice3, $Dice4, $Dice5, $Dice6, $Dice7]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func roll_random(dice_amount: int)-> Array: 
	
	AudioManager.play_sfx(sfx_diceroll)
	
	var generated_dices: Array = []
	
	randomize()
	for i in range(dice_amount):
		
		var dice_value: int = randi()%6 + 1
		
		if GameState.isCheater and GameController.current_encounter.current_turn == GameController.current_encounter.Turn.PLAYER:
			dice_value = 6
		
		var new_dice = dice_instance.instance()
		
		add_child(new_dice)
		
		generated_dices.append(new_dice)
		
		new_dice.connect("dice_picked_up", get_parent(), "_on_Dice_dice_picked_up")
		new_dice.connect("dice_dropped", get_parent(), "_on_Dice_dice_dropped")
		
		new_dice.set_dice_value(dice_value)
		
		new_dice.global_position = dice_positions[i].get_global_position() + Vector2(0, -360)
		
		new_dice.initial_position = dice_positions[i].get_global_position()
	
	return generated_dices
