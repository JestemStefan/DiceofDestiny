extends Node2D
class_name Encounter

onready var encounter_player: EncounterPlayer = $Encounter_Player
onready var player_sprite = $Encounter_Player/PlayerSprite
onready var player_animplayer: AnimationPlayer = $Encounter_Player/PlayerAnimationPlayer

onready var encounter_enemy: Node2D = $Encounter_Enemy
onready var enemy_sprite: Sprite
onready var enemy_animplayer: AnimationPlayer

onready var dices: Node2D = $Dices

var dice_in_hand: Dice
var dices_in_memory: Array

var picked_action: ActionBox

var enemy_stats: Resource

enum Environment_Type{FOREST, ISLAND, DESERT, SWAMP, BOSS, DM}
var encounter_environment: int = Environment_Type.FOREST


enum Turn{NOONE, PLAYER, ENEMY}
var current_turn: int = Turn.PLAYER

var action_buffer: Dictionary = {"Attack": 0,
								"Block": 0,
								"Heal": 0}

# Called when the node enters the scene tree for the first time.
func _ready():
	GameController.current_encounter = self


func start_encounter():
	
	var combat_platform_index: int = 0
	
	match encounter_environment:
		Environment_Type.FOREST: combat_platform_index = 2
		Environment_Type.ISLAND: pass
		Environment_Type.DESERT: combat_platform_index = 1
		Environment_Type.SWAMP: combat_platform_index = 0
		Environment_Type.BOSS: combat_platform_index = 3
		Environment_Type.DM: combat_platform_index = 4
	
	$Encounter_Enemy/Combat_Platform.frame = combat_platform_index
	$Encounter_Player/Combat_Platform.frame = combat_platform_index
	
	encounter_enemy.load_enemy_data(enemy_stats)
	
	player_animplayer.play("Idle")
	var player_tween:Tween = slide_player_in()
	var enemy_tween:Tween = slide_enemy_in()
	
	enemy_animplayer.play("Idle")
	
	yield(player_tween,"tween_completed")
	player_tween.call_deferred("free")
	
	yield(enemy_tween,"tween_completed")
	enemy_tween.call_deferred("free")
	
	
	$Encounter_Player/PlayerHealthbar.show()
	$Encounter_Player/UI_Player_Name/PlayerName.show()
	$Encounter_Player/UI_Player_HP.show()
	$Encounter_Enemy/EnemyHealthbar.show()
	$Encounter_Enemy/UI_Enemy_Name/EnemyName.show()
	$Encounter_Enemy/UI_Enemy_HP.show()
	
	$RollButton.show()
	$EndTurnButton.show()

	switch_turns(Turn.PLAYER) 


func slide_player_in():
	var player_tween: Tween = Tween.new()
	add_child(player_tween)
	var _err1 = player_tween.interpolate_property(player_sprite, 
										"offset", 
										player_sprite.offset, 
										Vector2(0,0), 
										2, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	var _err2 = player_tween.interpolate_property($Encounter_Player/Combat_Platform, 
										"offset", 
										$Encounter_Player/Combat_Platform.offset, 
										Vector2(0,0), 
										1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	var _err3 = player_tween.interpolate_property($Encounter_Player/UI_Player_Name, 
										"offset", 
										$Encounter_Player/UI_Player_Name.offset, 
										Vector2(0,0), 
										1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)

	var _err4 = player_tween.interpolate_property($UI_Player, 
										"offset", 
										$UI_Player.offset, 
										Vector2(0,0), 
										1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	var _tween_start = player_tween.start()
	
	return player_tween


func slide_enemy_in():
	var enemy_tween: Tween = Tween.new()
	add_child(enemy_tween)
	var _err1 = enemy_tween.interpolate_property(enemy_sprite, 
										"offset:x", 
										enemy_sprite.offset.x, 
										0, 
										2, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)

	var _err2 = enemy_tween.interpolate_property($Encounter_Enemy/Combat_Platform, 
											"offset:x", 
											$Encounter_Enemy/Combat_Platform.offset.x, 
											0, 
											1, 
											Tween.TRANS_CUBIC, 
											Tween.EASE_OUT)
		
	var _err3 = enemy_tween.interpolate_property($Encounter_Enemy/UI_Enemy_Name, 
											"offset:x", 
											$Encounter_Enemy/UI_Enemy_Name.offset.x, 
											0, 
											1, 
											Tween.TRANS_CUBIC, 
											Tween.EASE_OUT)
		
	var _err4 = enemy_tween.interpolate_property($UI_Enemy, 
											"offset:x", 
											$UI_Enemy.offset.x, 
											0, 
											1, 
											Tween.TRANS_CUBIC, 
											Tween.EASE_OUT)
	
	var _tween_start = enemy_tween.start()
	
	return enemy_tween


func end_encounter():
	GameController.current_board_tile.unlock_tiles()
	$BackToMapButton.hide()
	
	if enemy_stats.isBoss:
		GameState.add_dice()
		
	GameController.end_encounter()


func execute_buffer_actions():
	
	for action_name in action_buffer.keys():
		
		var action_value: int = action_buffer[action_name]
		
		if action_value > 0:
		
			match current_turn:
				
				Turn.PLAYER:
					match action_name:
						
						"Attack":
							encounter_enemy.take_damage(action_value)
							encounter_player.play_sound("Attack")
						
						"Block":
							encounter_player.get_block(action_value)
						
						"Heal":
							encounter_player.heal(action_value)
				
				Turn.ENEMY:
					match action_name:
						
						"Attack":
							encounter_player.take_damage(action_value)
						
						"Block":
							encounter_enemy.get_block(action_value)
							
						"Heal":
							encounter_enemy.heal(action_value)


func reset_action_buffer():
	
	for action_name in action_buffer.keys():
		action_buffer[action_name] = 0
	
	match current_turn:
		Turn.PLAYER:
			encounter_player.update_stats(action_buffer)
		
		Turn.ENEMY:
			encounter_enemy.update_stats(action_buffer)


func switch_turns(next_turn: int):
	
	#reset values in bufer
	for action_name in action_buffer.keys():
		
		action_buffer[action_name] = 0
	
	dices_in_memory = []
	
	for child in dices.get_children():
		if child is Dice:
			child.call_deferred("free")
	
	if encounter_enemy.current_state != encounter_enemy.State.DEAD:
		
		match next_turn:
			
			Turn.PLAYER:
				$RollButton.show()
				$RollButton.set_disabled(false)
				$UndoActionButton.show()
				$EndTurnButton.show()
				current_turn = Turn.PLAYER
				
				encounter_player.show_stuff()
				encounter_player.reset_block()
				
				encounter_enemy.hide_stuff()
				
			Turn.ENEMY:
				$RollButton.hide()
				$RollButton.set_disabled(true)
				$UndoActionButton.hide()
				$EndTurnButton.hide()
				
				encounter_player.hide_stuff()
				
				encounter_enemy.reset_block()
				encounter_enemy.show_stuff()
				
				current_turn = Turn.ENEMY
				
				encounter_enemy.play_turn()


func _on_EndTurnButton_button_up():
	
	execute_buffer_actions()
	reset_action_buffer()
	
	switch_turns(Turn.ENEMY)
	

func _on_RollButton_button_up():
	$RollButton.set_disabled(true)
	
	var generated_dices: Array = dices.roll_random(GameState.player_dice_amount)
	GameController.current_encounter.dices_in_memory = generated_dices
	
	var dice_tween: Tween = Tween.new()
	add_child(dice_tween)
	
	var dice_drop_delay: float = 0
	for dice in generated_dices:
	
		var _err1 = dice_tween.interpolate_property(dice, 
									"global_position:y", 
									null, 
									dice.initial_position.y, 
									1, 
									Tween.TRANS_BOUNCE, 
									Tween.EASE_OUT, 
									dice_drop_delay)
		
		var _err2 = dice_tween.interpolate_property(dice, 
									"global_position:x", 
									dice.global_position.x + rand_range(-500, 500), 
									dice.initial_position.x, 
									1, 
									Tween.TRANS_CUBIC, 
									Tween.EASE_OUT, 
									dice_drop_delay)
		
		dice_drop_delay += 0.1
	
	var _tween_start = dice_tween.start()
	yield(dice_tween, "tween_all_completed")
	dice_tween.call_deferred("free")
	
	
func _on_Encounter_Enemy_enemy_died():
	
	$RollButton.hide()
	$UndoActionButton.hide()
	$EndTurnButton.hide()
	
	#$Encounter_Player/Skills.hide()
	#$Encounter_Player/PlayerHealth.hide()
	
	encounter_enemy.hide_stuff()
	encounter_player.hide_stuff()
	
	dices.hide()
	
	var tween: Tween = Tween.new()
	add_child(tween)
	var _err = tween.interpolate_property(enemy_sprite, 
										"offset", 
										null, 
										Vector2(0,128), 1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	var _tween_start = tween.start()
	yield(tween, "tween_completed")
	
	$BackToMapButton.show()


func _on_BackToMapButton_button_up():
	end_encounter()


func _on_Dice_dice_picked_up(dice: Dice):
	dice.play_pick_up_sound()
	dice_in_hand = dice


func _on_Dice_dice_dropped(dice: Dice):
	if picked_action != null:
		dice.play_placement_sound()
		
		dice.last_position = picked_action.global_position
		dice.enter_state(dice.State.USED)
		dice.hide()
		
		picked_action.use_dice(dice_in_hand.dice_value)
		
		picked_action = null
		#dice.call_deferred("free")
		
		
	else:
		dice.play_drop_sound()
		dice.enter_state(dice.State.FREE)
	
	dice_in_hand = null


func _on_Action_Box_actionbox_triggered(action_name: String, dice_value: int):
	pass
	
	action_buffer[action_name] += dice_value
	
	match current_turn:
		Turn.PLAYER:
			encounter_player.update_stats(action_buffer)
		
		Turn.ENEMY:
			encounter_enemy.update_stats(action_buffer)


	

func _on_UndoActionButton_button_up():
	
	for action_name in action_buffer.keys():
		
		action_buffer[action_name] = 0
	
	match current_turn:
		Turn.PLAYER:
			encounter_player.update_stats(action_buffer)
		
		Turn.ENEMY:
			pass
	
	for hidden_dice in dices_in_memory:
		hidden_dice.enter_state(hidden_dice.State.FREE)
		hidden_dice.show()
		
		
