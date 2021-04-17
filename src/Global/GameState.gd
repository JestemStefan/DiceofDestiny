extends Node

var player_name: String = "Player"
var player_max_health: int = 30
var player_health: int = player_max_health

var player_skills = {"Attack":true,
					"Block": false,
					"Heal": false}

var player_dice_amount: int = 3
var last_dice_amount: int = player_dice_amount

var isCheater: bool = false

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


func level_up():
	match player_dice_amount:
		0: player_max_health = 30
		1: player_max_health = 30
		2: player_max_health = 30
		3: player_max_health = 30
		4: player_max_health = 40
		5: player_max_health = 50
		6: player_max_health = 60
		7: player_max_health = 70
	
	player_health = player_max_health

func unlock_player_skill(skill_name: String):
	player_skills[skill_name] = true


func add_dice():
	if !isCheater:
		player_dice_amount += 1
		
		if player_dice_amount > 7:
			player_dice_amount = 7
		
		last_dice_amount = player_dice_amount
		
	else:
		last_dice_amount += 1
		if last_dice_amount > 7:
			last_dice_amount = 7
	
	level_up()


func remove_dice():
	player_dice_amount -= 1


func activate_cheats():
	player_dice_amount = 7
	isCheater = true
	

func deavtivate_cheats():
	player_dice_amount = last_dice_amount
	isCheater = false
