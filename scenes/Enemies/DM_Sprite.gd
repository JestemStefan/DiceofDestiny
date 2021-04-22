extends Sprite

onready var nerd_hurt_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ_DMHits-001.ogg")
onready var sfx_DM_transformation: AudioStreamOGGVorbis = preload("res://sfx/GWJ_DMHello.ogg")


func _ready():
	pass # Replace with function body.


func transition():
	$EnemyAnimationPlayer.play("Transformation")


func change_to_nerd():
	GameController.current_encounter.encounter_enemy.enemy_hurt_sound = nerd_hurt_sound
	GameController.current_encounter.encounter_enemy.update_enemy_name("Dungeon Master")
	$EnemyAnimationPlayer.play("Idle2")


func play_transformation_sfx():
	AudioManager.play_sfx(sfx_DM_transformation)
