extends Resource
class_name EnemyStats

export var enemy_name: String
export var enemy_level: int = 1
export var isBoss: bool = false
export var enemy_sprite: PackedScene

export var enemy_dice_count: int = 1

export var enemy_max_health: int

export var attack_skill: bool
export var block_skill: bool
export var heal_skill: bool

var all_skills_dict: Dictionary

func get_enemyHP():
	return enemy_max_health


func get_enemy_skill_list():
	all_skills_dict = {"Attack": attack_skill,
						"Block": block_skill,
						"Heal": heal_skill}
						
	var available_skills: Array = []
	for skill in all_skills_dict:
		if all_skills_dict[skill] == true:
			available_skills.append(skill)

	return available_skills
