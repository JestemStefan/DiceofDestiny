extends Area2D
class_name InteractionBox

enum Action_type{ATTACK, DEFEND}
export(Action_type) var Action = Action_type.ATTACK
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func use_dice(dice_value: int):
	match Action:
		
		Action_type.ATTACK:
			print("You deal " + str(dice_value) + " damage")
		
		Action_type.DEFEND:
			print("You get " + str(dice_value) + " of armor")
