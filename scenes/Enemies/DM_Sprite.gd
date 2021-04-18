extends Sprite

onready var nerd_hurt_sound: AudioStreamOGGVorbis = preload("res://sfx/GWJ_DMHits-001.ogg")


func _ready():
	pass # Replace with function body.


func transition():
	$EnemyAnimationPlayer.play("Transformation")


func change_to_nerd():
	GameController.current_encounter.encounter_enemy.enemy_hurt_sound = nerd_hurt_sound
	$EnemyAnimationPlayer.play("Idle2")
