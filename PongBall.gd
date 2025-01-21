extends CharacterBody2D

var win_size : Vector2
const START_SPEED : int = 200
const ACCEl : int = 20
var speed : int
var dir : Vector2

func _ready() -> void:
	win_size = get_viewport_rect().size
	pass
	
func new_ball():
	position.x = win_size.x / 2
	position.y = randi_range(200, win_size.y - 200)
	speed = START_SPEED
	dir = random_direction()
	pass

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(dir * speed * delta)
	var collider
	if collision:
		collider = collision.get_collider()
		if collider == $"../Player":
			speed += ACCEl
			dir = dir.bounce(collision.get_normal())
		else:
			dir = dir.bounce(collision.get_normal())

func random_direction():
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()
