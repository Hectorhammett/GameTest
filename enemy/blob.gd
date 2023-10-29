extends CharacterBody2D

signal player_hit

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const IDLE = 0
const JUMPING = 1
const ON_AIR = 2
const FALLING = 3
const LANDING = 4
const STUNNED = 5
const LEFT = -1
const RIGHT = 1
const PLAYER_DAMAGE = 1

var state = IDLE
var direction = LEFT 
var hp = 5
var player_position

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	player_position = get_node("/root/PlayerPosition")


func _physics_process(delta):
	handle_direction()
	
	if !is_on_floor():
		handle_on_air(delta)
	else:
		handle_on_floor(delta)
	
	handle_animation()
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_hit.emit(PLAYER_DAMAGE)

func _on_animation_timer_timeout():
	if state == LANDING: 
		state = IDLE
		$AnimationTimer.wait_time = 1	
	elif state == IDLE:
		state = JUMPING
		$AnimationTimer.wait_time = 0.5
	elif state == JUMPING:
		$AnimationTimer.wait_time = 0.5
		hop()
	elif state == STUNNED:
		state = IDLE
	
	$AnimationTimer.start()
	

func handle_on_air(delta):
	velocity.y += gravity * delta
	if velocity.y > 0:
		state = FALLING
		$AnimatedSprite2D.animation = "on_air"
	
	if velocity.y < 1:
		state = ON_AIR
		$AnimatedSprite2D.animation = "jumping"
	
func handle_on_floor(_delta):
	if state == FALLING || state == STUNNED:
		state = LANDING
		velocity.x = 0
		$AnimationTimer.wait_time = 1
		$AnimationTimer.start()


func handle_animation():
	var STATES = {
		IDLE: "on_floor",
		JUMPING: "jumping",
		ON_AIR: "on_air",
		FALLING: "falling",
		LANDING: "landed",
		STUNNED: "stuned"
	}
	
	var animation_name = STATES[state]
	$AnimatedSprite2D.animation = animation_name

func hop():
	velocity.x = SPEED * direction
	velocity.y = JUMP_VELOCITY
	
func handle_direction():
	if position.x > player_position.value.x:
		direction = LEFT
		$AnimatedSprite2D.flip_h = true
	else:
		direction = RIGHT
		$AnimatedSprite2D.flip_h = false


func _on_area_2d_area_entered(area):
	if !area.is_in_group("projectiles"):
		return
	
	hp -= 1
	if hp <= 0:
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.disabled = true
		$Area2D/CollisionShape2D.disabled = true
		queue_free()
		return
	
	state = STUNNED
	$AnimationTimer.wait_time = 0.5
	$AnimationTimer.start()
