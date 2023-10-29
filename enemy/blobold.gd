extends Area2D

const SPEED = 100

var on_floor = false
var is_stunned = false
var y_velocity = 1
var hp = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.flip_h = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2.ONE * -1
	
	if !on_floor:
		handle_on_air(delta)
		return
	
	if is_stunned:
		handle_stunned()
		return
	
	position.x += velocity.x * delta * SPEED

func _on_area_entered(area):
	if area.is_in_group("projectiles"):
		print("hit!")
		handle_hit()

func handle_landing():
	on_floor = true
	y_velocity = 0

func handle_on_air(delta):
	if !on_floor:
		position.y += y_velocity * delta * SPEED
		y_velocity += 0.1 

func _on_body_entered(body):
	print(body.name)
	if body.name == "Floor":
		handle_landing()

func handle_hit():
	hp -= 1
	
	if hp <= 0:
		$AnimatedSprite2D.visible = false
		$CollisionShape2D.disabled = true
		queue_free()
		return
	
	is_stunned = true
	$Timer.start()

func _on_timer_timeout():
	print("timer ended")
	is_stunned = false
	$AnimatedSprite2D.animation = "walking"

func handle_stunned():
	$AnimatedSprite2D.animation = "damaged"	
