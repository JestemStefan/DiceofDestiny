extends Node2D
class_name EncounterEnemy

var enemy_name: String
var enemy_level: int
var enemy_dice_count: int
var enemy_max_health: int
var enemy_health: int
var enemy_block: int
var enemy_skills: Array

var enemy_actions: Dictionary = {"Attack": null,
								"Block": null,
								"Heal":null}
								
var enemy_stats: Dictionary = {"Attack": 0,
								"Block": 0,
								"Heal":0}

var action_box_instance: PackedScene = preload("res://scenes/InteractionBox/ActionBox.tscn")
onready var skill_positions: Array = [$EnemySkills/Skill1, $EnemySkills/Skill2, $EnemySkills/Skill3, $EnemySkills/Skill4, $EnemySkills/Skill5]

signal enemy_died

enum State{IDLE, DEAD}
var current_state: int = State.IDLE

onready var enemy_sprite: Sprite
onready var enemy_controller_tween: Tween = $EnemyControllerTween

onready var enemy_hand: Node2D = $EnemyFilthyHand
onready var enemy_hand_tween: Tween = $EnemyFilthyHand/HandTween

onready var hp_bar: ProgressBar = $EnemyHealthBar


var isShaking: bool = false
var initial_offset: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(_delta):
	if isShaking:
		enemy_sprite.set_offset(initial_offset + Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 2)


func enter_state(new_state: int):
	current_state = new_state
	
	match current_state:
		State.IDLE:
			pass
		
		State.DEAD:
			emit_signal("enemy_died")


func load_enemy_data(enemy_stats: Resource):
	enemy_name = enemy_stats.enemy_name
	$UI_Enemy_Name/EnemyName.text = enemy_name
	print("Enemy name: " + enemy_name)
	
	enemy_level = enemy_stats.enemy_level
	print("Level: " + str(enemy_level))
	
	var enemy_sprite_scene: Sprite = enemy_stats.enemy_sprite.instance()
	add_child(enemy_sprite_scene)
	
	update_enemy_sprite(enemy_sprite_scene)
	
	enemy_dice_count = enemy_stats.enemy_dice_count
	print("Enemy has " + str(enemy_dice_count) + " dices")
	
	enemy_max_health = enemy_stats.get_enemyHP()
	enemy_health = enemy_stats.get_enemyHP()
	print("HP: " + str(enemy_max_health))
	
	update_healthbar()
	
	enemy_skills = enemy_stats.get_enemy_skill_list()
	print(enemy_skills)
	
	create_action_box(enemy_skills)


func update_enemy_sprite(sprite: Sprite):
	enemy_sprite = sprite
	get_parent().enemy_sprite = $EnemySprite
	get_parent().enemy_animplayer = $EnemySprite/EnemyAnimationPlayer


func update_healthbar():
	
	hp_bar.max_value = enemy_max_health
	hp_bar.value = enemy_health


func update_block_amount():
	if enemy_block > 0:
		$EnemyBlock.show()
		$EnemyBlock/BlockAmount.text = str(enemy_block)
		
	else:
		$EnemyBlock.hide()


func update_stats(stats: Dictionary):
	
	enemy_stats = stats
	
	var text_to_insert: String = ""
	
	for stat_name in enemy_stats.keys():
		text_to_insert += str(enemy_stats[stat_name]) + " :" + stat_name + "\n"

	$EnemyStats.text = text_to_insert


func create_action_box(skill_list: Array):
	
	var skill_index: int = 0
	for skill in skill_list:

		var action_box: ActionBox = action_box_instance.instance()
		$EnemySkills.add_child(action_box)
		
		# save actions to dict
		enemy_actions[skill] = action_box
		
		action_box.global_position = skill_positions[skill_index].global_position
		
		skill_index += 1
		
		match skill:
			"Attack":
				action_box.set_actionbox_type(action_box.Action_type.ATTACK, false)

			"Block":
				action_box.set_actionbox_type(action_box.Action_type.BLOCK, false)

			"Heal":
				action_box.set_actionbox_type(action_box.Action_type.HEAL, false)


func take_damage(damage: int):
	damage = block_damage(damage)
	
	enemy_health -= damage
	
	if enemy_health <= 0:
		enter_state(State.DEAD)
	
	shake(true)
		
	#reduce damage by block value
	
	update_healthbar()
	yield(get_tree().create_timer(0.5), "timeout")
	shake(false)
	


func get_block(amount: int):
	enemy_block += amount
	update_block_amount()


func reset_block():
	enemy_block = 0
	update_block_amount()


func block_damage(damage: int):

	# reduce damage by block value
	var damage_left: int = damage - enemy_block
	
	enemy_block -= damage
	if enemy_block < 0:
		enemy_block = 0
	
	update_block_amount()
	
	if damage_left <= 0:
		return 0
	
	else:
		return damage_left


func heal(amount: int):
	enemy_health += amount
	
	if enemy_health > enemy_max_health:
		enemy_health = enemy_max_health
		
	update_healthbar()


func shake(on_off: bool):
	
	if on_off:
		initial_offset = enemy_sprite.get_offset()
		
	else:
		enemy_sprite.set_offset(initial_offset)
	
	isShaking = on_off


func move_hand(final_position: Vector2):
	# move hand on the dice
	var _eh_err = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, final_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	var _et_start = enemy_hand_tween.start()


func play_turn():
	
	# spawn dices for enemy
	var generated_dices: Array = GameController.current_encounter.dices.roll_random(enemy_dice_count)
	GameController.current_encounter.dices_in_memory = generated_dices
	
	# put dices on the screen
	for spawned_dice in generated_dices:
		var dice_tween: Tween = tween_dice(spawned_dice, spawned_dice.initial_position)
		yield(dice_tween, "tween_completed")
		dice_tween.call_deferred("free")
	
	# reset position of enemy hand visualization
	enemy_hand.global_position = enemy_sprite.global_position
	enemy_hand.show()
	
	
	# for every dice generated
	for dice in generated_dices:
		
		dice.emit_signal("dice_picked_up", dice)
		
		# move hand on the dice
		var _eh_err = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, dice.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		var _et_start = enemy_hand_tween.start()
		yield(enemy_hand_tween, "tween_completed")
		
		
		# select skill that dice will be spend on
		var selected_skill: ActionBox = pick_random_action()
		GameController.current_encounter.picked_action = selected_skill
		
		# move dice and enemy to the selected action box
		var _ec_err = enemy_controller_tween.interpolate_property(dice, "global_position", null, selected_skill.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		var _ec_start = enemy_controller_tween.start()
		
		_eh_err = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, selected_skill.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_et_start = enemy_hand_tween.start()
		
		yield(enemy_controller_tween, "tween_completed")
		yield(enemy_hand_tween, "tween_completed")
	
		#spend dice	
		#dice.enter_state(dice.State.USED)
		dice.emit_signal("dice_dropped", dice)
	
	
	var _rest_hand = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, enemy_sprite.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	var _rest_hand_start = enemy_hand_tween.start()
	
	yield(enemy_hand_tween, "tween_completed")
	enemy_hand.hide()
	
	
	GameController.current_encounter.execute_buffer_actions()
	GameController.current_encounter.reset_action_buffer()
	GameController.current_encounter.switch_turns(GameController.current_encounter.Turn.PLAYER)


func pick_random_action():
	
	var max_skill_index: int = len(enemy_skills)
	
	var random_skill_name: String = enemy_skills[randi()% max_skill_index]
	print("Enemy do: " + str(random_skill_name))
	return enemy_actions[random_skill_name]


func tween_dice(dice: Dice, final_pos: Vector2):
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(dice, 
								"global_position", 
								null, 
								final_pos, 
								0.3, 
								Tween.TRANS_BOUNCE, 
								Tween.EASE_OUT)
	tween.start()
	
	return tween


func hide_stuff():
	$UI_Enemy_Stats.hide()
	$EnemyStats.hide()
	$UI_Enemy_HP.hide()
	$EnemySkills.hide()


func show_stuff():
	$UI_Enemy_Stats.show()
	$EnemyStats.show()
	$UI_Enemy_HP.show()
	$EnemySkills.show()
