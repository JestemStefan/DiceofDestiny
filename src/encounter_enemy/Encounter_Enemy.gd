extends Node2D

enum State{IDLE, DEAD}
var current_state: int = State.IDLE

var enemy_max_health: int = 10
var enemy_health: int = 7

onready var enemy_sprite: Sprite = $EnemySprite
onready var hp_bar: ProgressBar = $EnemyHealthBar

var isShaking: bool = false

signal enemy_died

# Called when the node enters the scene tree for the first time.
func _ready():
	update_healthbar()


func _process(delta):
	if isShaking:
		enemy_sprite.set_offset(Vector2(rand_range(-1, 1), rand_range(-1, 1)) * 2)


func enter_state(new_state: int):
	current_state = new_state
	
	match current_state:
		State.IDLE:
			pass
		
		State.DEAD:
			emit_signal("enemy_died")


func update_healthbar():
	
	hp_bar.max_value = enemy_max_health
	hp_bar.value = enemy_health


func take_damage(damage: int):
	enemy_health -= damage
	update_healthbar()
	
	shake(true)
	yield(get_tree().create_timer(0.5), "timeout")
	shake(false)
	
	if enemy_health <= 0:
		$EnemySprite.hide()
		$EnemyHealthBar.hide()
		
		enter_state(State.DEAD)


func shake(on_off: bool):
	isShaking = on_off
