extends CharacterBody3D


const SPEED = 4.0
const JUMP_VELOCITY = 5.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity :float = 9.8

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var mesh: Node3D = $Mesh
@onready var right_socket: Node3D = $Mesh/GeneralSkeleton/RightHandAttachment/RightSocket
@onready var left_socket: Node3D = $Mesh/GeneralSkeleton/LeftHandAttachment/LeftSocket



@export var is_flipped : bool = false

var state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
	state_machine = $AnimationTree.get("parameters/playback")
	
	pass	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	print("direction: ", direction)
	#print("input_dir: ", input_dir)
	#var direction = (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	#
	#print("basis: ",transform.basis," direction: ", direction)
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = 0.0#direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		velocity.z = 0.0
	
	
	if velocity.x >0 and is_flipped:
		change_player_direction()
	elif velocity.x < 0 and not is_flipped:
		change_player_direction()
	
	animation_tree.set("parameters/Moviment/blend_position", direction.x)
	
	print($AnimationPlayer.current_animation)
	
	#animation_tree.set("")
	
	move_and_slide()

func change_player_direction()->void:
	
	if is_flipped :
		var spear = left_socket.get_child(0)
		if spear:
			left_socket.remove_child(spear)
			right_socket.add_child(spear)
			spear.rotation = Vector3.ZERO
			spear.position = Vector3.ZERO
	else:
		var spear = right_socket.get_child(0)
		if spear:
			right_socket.remove_child(spear)
			left_socket.add_child(spear)
			spear.rotation = Vector3.ZERO
			spear.position = Vector3.ZERO
	
	is_flipped = not is_flipped
	mesh.rotation.y *= -1
	mesh.position.x *= -1
	
	

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action("ui_throw") :
		throw_spear()



func throw_spear()->void:
	state_machine.travel("Throw")
	pass

