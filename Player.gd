extends CharacterBody2D

   #Does this belong here ??? Will the instantiation be an issue ?
const PADDLE_SPEED : int = 500
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var win_height : int
var p_height : int

func _ready() -> void:
	win_height = get_viewport_rect().size.y
	p_height = $ColorRect.get_size().y
	pass

func _physics_process(delta: float) -> void:
	if name == str(multiplayer.get_unique_id()):
		if Input.is_action_pressed("ui_up"):
			position.y -= PADDLE_SPEED * delta
		elif Input.is_action_pressed("ui_down"):
			position.y += PADDLE_SPEED * delta
		
		position.y = clamp(position.y, p_height / 2, win_height - p_height / 2)
		# Add the gravity.
		#if not is_on_floor():
			#velocity += get_gravity() * delta
#
		## Handle jump.
		#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			#velocity.y = JUMP_VELOCITY
#
		## Get the input direction and handle the movement/deceleration.
		## As good practice, you should replace UI actions with custom gameplay actions.
		#var direction := Input.get_axis("ui_left", "ui_right")
		#if direction:
			#velocity.x = direction * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
#
		#move_and_slide()
		syncPos.rpc(global_position)

@rpc("any_peer")
func syncPos(p):
	global_position = p
