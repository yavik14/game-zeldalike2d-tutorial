extends CharacterBody2D

signal healthChanged

@export var speed: int = 35
@export var maxHealth: int = 3
@export var knockbackPower: int = 500

@export var inventory: Inventory

@onready var animations = $AnimationPlayer
@onready var effects = $Effects
@onready var hurtTimer = $HurtTimer
@onready var weapon = $Weapon

@onready var currentHealth: int = maxHealth

var isHurt: bool = false
var enemyCollisions = []
var lastAnimDirection: String = "Down"
var isAttacking: bool = false

func _ready():
	weapon.visible = false
	effects.play("RESET")

func handleInput():
	var moveDirection = Input.get_vector( "ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if Input.is_action_just_pressed("attack"):
		attack()
		
func attack():
	animations.play("attack" + lastAnimDirection)
	isAttacking = true
	weapon.enable()
	await animations.animation_finished
	isAttacking = false
	weapon.disable()
	
func updateAnimation():
	if isAttacking: return
	if velocity.length() == 0:
		if animations.is_playing():
			animations.stop()
	var direction = "Down"
	if velocity.x < 0: direction = "Left"
	elif velocity.x > 0: direction = "Right"
	elif velocity.y < 0: direction = "Up"
	
	animations.play("walk" + direction)
	lastAnimDirection = direction
	
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
	elif area.has_method("collect"):
		area.collect(inventory)
		
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
