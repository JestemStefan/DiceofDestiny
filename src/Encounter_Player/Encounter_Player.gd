extends Node2D
class_name EncounterPlayer

var action_box_instance: PackedScene = preload("res://scenes/InteractionBox/ActionBox.tscn")
onready var skill_positions: Array = [$Skills/Skill1, $Skills/Skill2, $Skills/Skill3, $Skills/Skill4, $Skills/Skill5]

onready var player_sprite: Sprite = $PlayerSprite

var player_hp: int
var player_maxHP: int
var player_block: int

var isShaking: bool = false
var shake_offest: float = 2

func _ready():
	update_player_info()


func _process(_delta):
	if isShaking:
		player_sprite.set_offset(Vector2(rand_range(-1, 1), rand_range(-1, 1)) * shake_offest)

# get info about player stats from GameState
func update_player_info():
	var skill_list: Array = GameState.get_player_skill_list()
	
	create_action_box(skill_list)
	
	player_hp = GameState.player_health
	player_maxHP = GameState.player_max_health
	player_block = 0
	
	update_healthbar()
	update_block_amount()


func create_action_box(skill_list: Array):
	
	var skill_index: int = 0
	for skill in skill_list:

		var action_box: ActionBox = action_box_instance.instance()
		$Skills.add_child(action_box)
		action_box.global_position = skill_positions[skill_index].global_position
		
		skill_index += 1
		
		match skill:
			"Attack":
				action_box.set_actionbox_type(action_box.Action_type.ATTACK)

			"Block":
				action_box.set_actionbox_type(action_box.Action_type.BLOCK)

			"Heal":
				action_box.set_actionbox_type(action_box.Action_type.HEAL)
	
	
	
func update_healthbar():
	$PlayerHealth.max_value = player_maxHP
	$PlayerHealth.value = player_hp


func update_block_amount():
	$BlockAmount.text = "Block: " + str(player_block)
	
	if player_block <= 0:
		$BlockAmount.hide()
	else:
		$BlockAmount.show()


func take_damage(damage: int):
	
	shake(true)
	
	#reduce damage by block value
	damage = block_damage(damage)
	
	
	player_hp -= damage
	
	update_healthbar()
	yield(get_tree().create_timer(0.5), "timeout")
	shake(false)
	
	GameState.player_health = player_hp


func get_block(amount: int):
	player_block += amount
	update_block_amount()


func reset_block():
	player_block = 0
	update_block_amount()


func block_damage(damage: int):

	# reduce damage by block value
	var damage_left: int = damage - player_block
	
	player_block -= damage
	if player_block < 0:
		player_block = 0
	
	update_block_amount()
	
	if damage_left <= 0:
		return 0
	
	else:
		return damage_left


func heal(amount: int):
	player_hp += amount
	
	if player_hp > player_maxHP:
		player_hp = player_maxHP
	
	update_healthbar()


func shake(on_off: bool, shake_strength: float = 2):
	isShaking = on_off
	shake_offest = shake_strength


func hide_stuff():
	$UI_Player_Stats.hide()
	$UI_Player_HP.hide()
	$Skills.hide()


func show_stuff():
	$UI_Player_Stats.show()
	$UI_Player_HP.show()
	$Skills.show()
