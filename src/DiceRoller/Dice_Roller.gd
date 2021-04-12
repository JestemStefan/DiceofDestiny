extends Node2D

onready var dice_instance: PackedScene = preload("res://scenes/Dice/Test_Dice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func roll_random(dice_amount: int):
	
	var generated_dices: Array = []
	
	randomize()
	for i in range(dice_amount):
		
		var dice_value: int = randi()%6 + 1
		#print("Dice value: " + str(dice_value))
		
		var new_dice = dice_instance.instance()
		
		add_child(new_dice)
		
		generated_dices.append(new_dice)
		
		new_dice.connect("dice_used", get_parent(), "_on_Dice_dice_used")
		
		new_dice.set_dice_value(dice_value)
		
		new_dice.translate(Vector2(-dice_amount * 16 + i * 36, 0))
		new_dice.initial_position = new_dice.get_global_position()
	
	return generated_dices
