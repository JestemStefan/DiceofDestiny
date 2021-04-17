extends Node2D
class_name EncounterPlayer

var action_box_instance: PackedScene = preload("res://scenes/InteractionBox/ActionBox.tscn")
onready var skill_positions: Array = [$Skills/Skill1, $Skills/Skill2, $Skills/Skill3, $Skills/Skill4, $Skills/Skill5]

onready var player_sprite: Sprite = $PlayerSprite

onready var player_sfx: AudioStreamPlayer = $Player_SFX
onready var hurt_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ32_RecieveDamage_PlayerGWJ_DiceDungeon_VOX-003.ogg")
onready var attack_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ32_Skills_AttackGWJ_Skills_Attack-001.ogg")
onready var defend_sound:  AudioStreamOGGVorbis = preload("res://sfx/GWJ32_Skills_DefendGWJ_Skills_Defend-001.ogg")

var player_hp: int
var player_maxHP: int
var player_block: int

var player_stats: Dictionary  = {"Attack": 0,
								"Block": 0,
								"Heal": 0}

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
	
	$UI_Player_Name/PlayerName.text = GameState.player_name
	player_hp = GameState.player_health
	player_maxHP = GameState.player_max_health
	player_block = 0
	
	update_healthbar()
	update_block_amount()
	update_stats(player_stats)


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
	print("Player block: " + str(player_block))
	if player_block > 0:
		$PlayerBlock.show()
		$PlayerBlock/BlockAmount.text = str(player_block)
		
	else:
		$PlayerBlock.hide()


func update_stats(stats: Dictionary):
	
	player_stats = stats
	
	var text_to_insert: String = ""
	
	for stat_name in player_stats.keys():
		text_to_insert += stat_name + ": " + str(player_stats[stat_name]) + "\n"

	$PlayerStats.text = text_to_insert


func take_damage(damage: int):
	
	shake(true)
	
	#reduce damage by block value
	damage = block_damage(damage)
	
	if damage > 0:
		play_sound("Hurt")
	else:
		play_sound("Block")
	
	if !GameState.isCheater:
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
	$PlayerStats.hide()
	#$UI_Player_HP.hide()
	$Skills.hide()


func show_stuff():
	$UI_Player_Stats.show()
	$PlayerStats.show()
	#$UI_Player_HP.show()
	$Skills.show()


func play_sound(sound_name: String):
	
	match sound_name:
		"Attack":
			player_sfx.stream = attack_sound
		
		"Block":
			player_sfx.stream = defend_sound
			
		"Hurt":
			player_sfx.stream = hurt_sound
	
	player_sfx.play()
