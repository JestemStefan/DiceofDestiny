extends Node2D
class_name Encounter

onready var encounter_player: Node2D = $Encounter_Player
onready var player_sprite = $Encounter_Player/PlayerSprite

onready var encounter_enemy: Node2D = $Encounter_Enemy
onready var enemy_sprite = $Encounter_Enemy/EnemySprite

enum Turn{NOONE, PLAYER, ENEMY}
var current_turn: int = Turn.NOONE


# Called when the node enters the scene tree for the first time.
func _ready():
	GameController.current_encounter = self


func start_encounter():
	slide_player_in()
	$Encounter_Player/PlayerHealth.show()
	
	slide_enemy_in()
	$Encounter_Enemy/EnemyHealthBar.show()
	
	$RollButton.show()
	$EndTurnButton.show()

	current_turn = Turn.PLAYER


func slide_player_in():
	var player_tween: Tween = Tween.new()
	add_child(player_tween)
	player_tween.interpolate_property(player_sprite, 
										"offset", 
										player_sprite.offset, 
										Vector2(0,0), 1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	player_tween.start()
	yield(player_tween, "tween_completed")
	player_tween.call_deferred("free")


func slide_enemy_in():
	var enemy_tween: Tween = Tween.new()
	add_child(enemy_tween)
	enemy_tween.interpolate_property(enemy_sprite, 
										"offset", 
										enemy_sprite.offset, 
										Vector2(0,0), 1, 
										Tween.TRANS_CUBIC, 
										Tween.EASE_OUT)
	
	enemy_tween.start()
	yield(enemy_tween, "tween_completed")
	enemy_tween.call_deferred("free")


func end_encounter():
	GameController.end_encounter()


func _on_Dice_dice_used():
	pass


func _on_EndTurnButton_button_up():
	$RollButton.set_disabled(false)


func _on_Action_Box_actionbox_triggered(action_name: String, dice_value: int):
	match current_turn:
		
		Turn.PLAYER:
			match action_name:
				
				"Attack":
					encounter_enemy.take_damage(dice_value)
				
				"Block":
					encounter_enemy.take_damage(dice_value)


func _on_RollButton_button_up():
	$Dices.roll_random(GameState.player_dice_amount)
	$RollButton.set_disabled(true)


func _on_Encounter_Enemy_enemy_died():
	$RollButton.hide()
	$EndTurnButton.hide()
	
	$Encounter_Player/Skills.hide()
	$Encounter_Player/PlayerHealth.hide()
	$Dices.hide()
	
	$BackToMapButton.show()


func _on_BackToMapButton_button_up():
	end_encounter()
