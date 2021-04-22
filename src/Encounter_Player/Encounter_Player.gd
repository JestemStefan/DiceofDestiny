extends Node2D
class_name EncounterPlayer

var action_box_instance: PackedScene = preload("res://scenes/InteractionBox/ActionBox.tscn")
onready var skill_positions: Array = [$Skills/Skill1, $Skills/Skill2, $Skills/Skill3, $Skills/Skill4, $Skills/Skill5]

onready var player_sprite: Sprite = $PlayerSprite
onready var special_seven_label: Label = $PlayerSpecialLabel

onready var boost_animplayer: AnimationPlayer = $BoostAnimation

onready var hurt_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ32_RecieveDamage_PlayerGWJ_DiceDungeon_VOX-003.ogg")
onready var attack_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ32_Skills_AttackGWJ_Skills_Attack-001.ogg")
onready var defend_sound:  AudioStreamOGGVorbis = preload("res://sfx/GWJ32_Skills_DefendGWJ_Skills_Defend-001.ogg")
onready var player_special_sfx: AudioStreamOGGVorbis = preload("res://sfx/GWJ_PowerUp2.ogg")

var player_hp: int
var player_maxHP: int
var player_block: int

var isDead: bool = false
signal player_died

var player_stats: Dictionary  = {"Attack": 0,
								"Block": 0,
								"Heal": 0,
								"7": 0}

var isShaking: bool = false
var shake_offest: float = 2

var isSpecialSevenOn: bool = false


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
			
			"7":
				action_box.set_actionbox_type(action_box.Action_type.SEVEN)
	
	
	
func update_healthbar():
	$PlayerHealthbar.setup_hp_bar(player_maxHP)
	$PlayerHealthbar.update_healthbar(player_hp)


func update_block_amount():
	if player_block > 0:
		$PlayerBlock.show()
		$PlayerBlock/BlockAmount.text = str(player_block)
		
	else:
		$PlayerBlock.hide()


func update_stats(stats: Dictionary):
	
	check_special_seven()
	
	player_stats = stats
	
	var text_to_insert: String = ""
	
	var boost: int = 1
	if isSpecialSevenOn:
		boost = 2
	
	
	for stat_name in player_stats.keys():
		match stat_name:
			"Attack":
				text_to_insert += stat_name + ": " + str(player_stats[stat_name] * boost) + "\n"
			
			"Block":
				text_to_insert += stat_name + ": " + str(player_stats[stat_name] * boost) + "\n"
			
			"Heal":
				text_to_insert += stat_name + ": " + str(player_stats[stat_name] * boost) + "\n"
				
			"7":
				
				if player_stats[stat_name] > 0:
					special_seven_label.show()
					special_seven_label.text = str(player_stats[stat_name])
				else:
					special_seven_label.hide()
					special_seven_label.text = ""

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
	
	if player_hp <= 0:
		isDead = true
		emit_signal("player_died")
		GameController.player_died()


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
	
	if isShaking == false:
		player_sprite.offset = Vector2.ZERO


func hide_stuff():
	$UI_Player_Stats.hide()
	$PlayerStats.hide()
	
	$Skills.hide()


func show_stuff():
	$UI_Player_Stats.show()
	$PlayerStats.show()
	
	$Skills.show()


func play_sound(sound_name: String):
	
	match sound_name:
		"Attack":
			AudioManager.play_sfx(attack_sound)
		
		"Block":
			AudioManager.play_sfx(defend_sound)
			
		"Hurt":
			AudioManager.play_sfx(hurt_sound)
	


func check_special_seven():
	if player_stats["7"] == 7:
		if isSpecialSevenOn == false:
			AudioManager.play_sfx(player_special_sfx)
		
		isSpecialSevenOn = true
		
		boost_animplayer.play("BoostON")
		
	else:
		isSpecialSevenOn = false
		boost_animplayer.play("BoostOFF")

