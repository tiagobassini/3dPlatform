extends CharacterBody3D

@export var spear_scene: PackedScene 

const SPEED = 4.0
const JUMP_VELOCITY = 7.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity :float = 18.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var mesh: Node3D = $Mesh
@onready var right_socket: Node3D = $Mesh/GeneralSkeleton/RightHandAttachment/RightSocket
@onready var left_socket: Node3D = $Mesh/GeneralSkeleton/LeftHandAttachment/LeftSocket
@onready var throw_position: Marker3D = $ThrowPosition
@onready var spear_respawn_timer: Timer = $SpearRespawnTimer

var current_spear: Spear

@export var is_flipped : bool = false
@export var is_attacking : bool = false

var state_machine: AnimationNodeStateMachinePlayback



func _ready() -> void:
	state_machine = $AnimationTree.get("parameters/playback")
	current_spear = right_socket.get_child(0)
	if current_spear == null:
		current_spear = left_socket.get_child(0)
	
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
	#print("direction: ", direction)
	#print("input_dir: ", input_dir)
	#var direction = (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	#
	#print("basis: ",transform.basis," direction: ", direction)
	
	if direction and not is_attacking:
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
	
	#print($AnimationPlayer.current_animation)
	
	#animation_tree.set("")
	
	move_and_slide()

func change_player_direction()->void:
	if current_spear !=null: 
		if is_flipped  :
			left_socket.remove_child(current_spear)
			right_socket.add_child(current_spear)
			current_spear.rotation = Vector3.ZERO
			current_spear.position = Vector3.ZERO
		else:
			right_socket.remove_child(current_spear)
			left_socket.add_child(current_spear)
			current_spear.rotation = Vector3.ZERO
			current_spear.position = Vector3.ZERO
		
	is_flipped = not is_flipped
	mesh.rotation.y *= -1
	mesh.position.x *= -1
	throw_position.position.x *= -1
	
	

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action("ui_throw") :
		throw_spear()



func throw_spear()->void:
	is_attacking = false
	state_machine.travel("Throw")
	
	pass


func shoot_spear()->void:
	print("spear shooted!")
	if not  current_spear:
		return
	
	var socket = current_spear.get_parent()
	socket.remove_child(current_spear)
	
	
	get_tree().root.add_child(current_spear)
	current_spear.global_position = throw_position.global_position
	current_spear.is_flipped = is_flipped
	current_spear.throwed = true
	current_spear = null
	spear_respawn_timer.start()
	pass

func reload_spear() ->void:
	current_spear = spear_scene.instantiate()
	
	if is_flipped:
		left_socket.add_child(current_spear)
	else:
		right_socket.add_child(current_spear)
	current_spear.position = Vector3.ZERO
	current_spear.position = Vector3.ZERO

func on_animation_finished(anim_name: StringName) -> void:
	#print("-----  anim_name: ", anim_name)
	if anim_name.to_lower().contains("attack"):
		is_attacking = false
	pass # Replace with function body.
	reload_spear()




func spear_respawn_timeout() -> void:
	reload_spear()
	pass # Replace with function body.
