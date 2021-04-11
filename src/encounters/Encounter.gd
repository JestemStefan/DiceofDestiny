extends Node2D
class_name Encounter


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start_encounter():
	$Dice_Roller.roll_random(7)


func _on_Dice_dice_used():
	yield(get_tree(), "idle_frame")
	print($Dice_Roller.get_child_count())
	
	if $Dice_Roller.get_child_count() <= 0:
		GameController.end_encounter()
		call_deferred("free")
