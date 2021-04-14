extends Node

var player_max_health: int = 50
var player_health: int = player_max_health

var player_skills = {"Attack":true,
					"Block": false,
					"Heal": false}

var player_dice_amount: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	get_player_skill_list()
	unlock_player_skill("Block")
	unlock_player_skill("Heal")
	get_player_skill_list()



func get_player_skill_list():
	var available_skill_list: Array = []
	
	for skill in player_skills:
		if player_skills[skill] == true:
			available_skill_list.append(skill)
	
	return available_skill_list


func unlock_player_skill(skill_name: String):
	player_skills[skill_name] = true


func add_dice():
	player_dice_amount += 1


func remove_dice():
	player_dice_amount -= 1
