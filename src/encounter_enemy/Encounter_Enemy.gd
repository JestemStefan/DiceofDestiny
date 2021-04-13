extends Node2D
class_name EncounterEnemy

export(Resource) var enemy_stats

var enemy_name: String
var enemy_level: int
var enemy_dice_count: int
var enemy_max_health: int
var enemy_health: int
var enemy_block: int
var skills: Array

signal enemy_died

enum State{IDLE, DEAD}
var current_state: int = State.IDLE

onready var enemy_sprite: Sprite = $EnemySprite
onready var enemy_controller_tween: Tween = $EnemyControllerTween

onready var enemy_hand: Node2D = $EnemyFilthyHand
onready var enemy_hand_tween: Tween = $EnemyFilthyHand/HandTween

onready var hp_bar: ProgressBar = $EnemyHealthBar


var isShaking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_enemy_data()
	update_healthbar()


func _process(_delta):
	if isShaking:
		enemy_sprite.set_offset(Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 2)


func enter_state(new_state: int):
	current_state = new_state
	
	match current_state:
		State.IDLE:
			pass
		
		State.DEAD:
			emit_signal("enemy_died")


func load_enemy_data():
	enemy_name = enemy_stats.enemy_name
	print("Enemy name: " + enemy_name)
	
	enemy_level = enemy_stats.enemy_level
	print("Level: " + str(enemy_level))
	
	enemy_dice_count = enemy_stats.enemy_dice_count
	print("Enemy has " + str(enemy_dice_count) + " dices")
	
	enemy_max_health = enemy_stats.get_enemyHP()
	enemy_health = enemy_stats.get_enemyHP()
	print("HP: " + str(enemy_max_health))
	
	skills = enemy_stats.get_enemy_skill_list()
	print(skills)


func update_healthbar():
	
	hp_bar.max_value = enemy_max_health
	hp_bar.value = enemy_health


func update_block_amount():
	$EnemyBlockAmount.text = "Block: " + str(enemy_block)
	if enemy_block <= 0:
		$EnemyBlockAmount.hide()
	else:
		$EnemyBlockAmount.show()


func take_damage(damage: int):
	shake(true)
	
	#reduce damage by block value
	damage = block_damage(damage)
	
	enemy_health -= damage
	
	update_healthbar()
	yield(get_tree().create_timer(0.5), "timeout")
	shake(false)
	
	if enemy_health <= 0:
		$EnemySprite.hide()
		$EnemyHealthBar.hide()
		
		enter_state(State.DEAD)


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
	update_healthbar()

func shake(on_off: bool):
	isShaking = on_off


func play_turn():
	
	var generated_dices: Array = GameController.current_encounter.dices.roll_random(enemy_dice_count)
	
	for spawned_dice in generated_dices:
		var dice_tween: Tween = tween_dice(spawned_dice, spawned_dice.initial_position)
		yield(dice_tween, "tween_completed")
		dice_tween.call_deferred("free")
	
	enemy_hand.global_position = enemy_sprite.global_position
	enemy_hand.show()
	
	for dice in generated_dices:
		
		var selected_skill: ActionBox = $EnemySkills/Action_Box
		
		var _eh_err = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, dice.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		var _et_start = enemy_hand_tween.start()
		
		yield(enemy_hand_tween, "tween_completed")
		
		var _ec_err = enemy_controller_tween.interpolate_property(dice, "global_position", null, selected_skill.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		var _ec_start = enemy_controller_tween.start()
		
		_eh_err = enemy_hand_tween.interpolate_property(enemy_hand, "global_position", null, selected_skill.global_position, 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		_et_start = enemy_hand_tween.start()
		
		yield(enemy_controller_tween, "tween_completed")
		yield(enemy_hand_tween, "tween_completed")
	
		
		dice.enter_state(dice.State.USED)
		dice.interaction_box.use_dice(dice.dice_value)
		dice.emit_signal("dice_used")
		dice.call_deferred("free")
	
	enemy_hand.hide()
	GameController.current_encounter.switch_turns(GameController.current_encounter.Turn.PLAYER)


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
