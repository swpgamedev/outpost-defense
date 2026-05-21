extends CharacterBody3D

@export var debug : bool

@export var SPEED : float = 5.0
@export var acceleration : float = 10
@export var deceleration : float = 10
@export var JUMP_VELOCITY : float = 4.5
@export var rotationSpeed : float = 30

@export var cam : Camera3D
@export var body_mesh: MeshInstance3D # may need to be just Node3D

var input_dir : Vector2
var forwardRelative : Vector3
var rightRelative : Vector3
var relativeInput : Vector3
var direction : Vector3

var lookTarget : Vector3
var lastLookTarget : Vector3

# Now living on sword_test.gd
#func _unhandled_input(_event) :
	#if Input.is_action_just_pressed("attack") and animPlayer.current_animation != "shoot" :
		#attack_effects()

func _process(delta: float) -> void:
	if (relativeInput != Vector3.ZERO) :
		var rotationTarget : Quaternion = Basis.looking_at(relativeInput, Vector3.UP, true).orthonormalized()
		# Only y axis rotation go here
		var newRotation : Quaternion = body_mesh.basis.orthonormalized().slerp(rotationTarget, delta * rotationSpeed)
		
		body_mesh.basis = newRotation
		
	#elif (lookTarget != Vector3.ZERO) :
		#var rotationTarget : Quaternion = Basis.looking_at(transform.origin - lookTarget, Vector3.UP).orthonormalized()
		# Only y axis rotation go here
		#var newRotation : Quaternion = body_mesh.basis.orthonormalized().slerp(rotationTarget, delta * rotationSpeed)
		#
		#body_mesh.basis = newRotation
		#sword_pivot.basis = newRotation
	
	
	lastLookTarget = lookTarget
	
		# DEBUG
	if (debug) :
		DebugDraw.draw_line_relative_thick(body_mesh.global_position, body_mesh.global_basis.x, 2, Color.RED)
		DebugDraw.draw_line_relative_thick(body_mesh.global_position, body_mesh.global_basis.y, 2, Color.GREEN)
		DebugDraw.draw_line_relative_thick(body_mesh.global_position, body_mesh.global_basis.z, 2, Color.BLUE)
		
		DebugDraw.draw_line_relative_pointy(body_mesh.global_position, velocity, 2, Color(1, 1, 0, 0.25))
		DebugDraw.draw_line_relative_pointy(body_mesh.global_position, relativeInput.normalized() * 2, 5, Color.CYAN)
		DebugDraw.draw_line_relative_pointy(body_mesh.global_position, direction.normalized(), 10, Color.PURPLE)
		


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	# Get the input direction and handle the movement/deceleration.
	
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	forwardRelative = input_dir.y * cam.global_basis.z
	forwardRelative = Vector3(forwardRelative.x, 0, forwardRelative.z).normalized()
	rightRelative = input_dir.x * cam.global_basis.x
	relativeInput = (forwardRelative + rightRelative).normalized()
	relativeInput.y = 0
	
	direction = (transform.basis * relativeInput).normalized()
	#direction.y = 0
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, acceleration)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)
	
	
	move_and_slide()
