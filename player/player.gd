extends CharacterBody2D

signal healthChanged

@export var speed: int = 35
@export var maxHealth: int = 3
@export var knockbackPower: int = 500

var isHurt: bool = false
var enemyCollisions = []

@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtTimer = $HurtTimer

@onready var currentHealth: int = maxHealth

func _ready():
	effects.play("RESET")

func handleInput():
	var moveDirection = Input.get_vector( "ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
func updateAnimation():
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	var direction = "Down"
	if velocity.x < 0: direction = "Left"
	elif velocity.x > 0: direction = "Right"
	elif velocity.y < 0: direction = "Up"
	
	animations.play("walk" + direction)
	
func _physics_process(delta):
	handleInput()
	move_and_slide()
	updateAnimation()
	if !isHurt:
		for enemyArea in enemyCollisions:
			hurtByEnemy(enemyArea)
		
func _on_hurt_box_area_entered(area):
	if area.name == "HitBox":
		enemyCollisions.append(area)
		
func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity-velocity).normalized() * knockbackPower
	velocity = knockbackDirection
	move_and_slide()
	
func hurtByEnemy(area):
	currentHealth -= 1
	if currentHealth < 0:
		currentHealth = maxHealth
		
	healthChanged.emit(currentHealth)
	isHurt = true
	knockback(area.get_parent().velocity)
	effects.play("hurtBlink")
	hurtTimer.start()
	await hurtTimer.timeout
	effects.play("RESET")
	isHurt = false


func _on_hurt_box_area_exited(area):
	enemyCollisions.erase(area) # Replace with function body.
