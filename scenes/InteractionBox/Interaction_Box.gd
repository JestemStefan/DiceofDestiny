extends Area2D
class_name InteractionBox

enum Action_type{ATTACK, DEFEND}
export(Action_type) var Action = Action_type.ATTACK
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	match Action:
		
		Action_type.ATTACK: $Box_Sprite.self_modulate = Color.lightcoral
		Action_type.DEFEND: $Box_Sprite.self_modulate = Color.lightblue

func use_dice(dice_value: int):
	match Action:
		
		Action_type.ATTACK:
			print("You deal " + str(dice_value) + " damage")
		
		Action_type.DEFEND:
			print("You get " + str(dice_value) + " of armor")
