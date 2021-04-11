extends Node2D

onready var dice_instance: PackedScene = preload("res://scenes/Dice/Test_Dice.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	if Input.is_action_just_pressed("ui_select"):
		roll_random(7)


func roll_random(dice_amount: int):
	
	for i in range(dice_amount):
		
		var dice_value: int = randi()%6 + 1
		print("Dice value: " + str(dice_value))
		
		var new_dice = dice_instance.instance()
		
		add_child(new_dice)
		
		new_dice.set_dice_value(dice_value)
		
		new_dice.translate(Vector2(0, i * 36))
		new_dice.initial_position = new_dice.get_global_position()
