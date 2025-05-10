extends CharacterBody3D
class_name Player

@export var spear_scene: PackedScene 

@export var SPEED = 2.0
@export var JUMP_VELOCITY = 7.5
@export var SHOOT_SPEED = 4.0

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
	reload_spear()	
	pass	

func _physics_process(delta):
	# Add the gravity.
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction and not is_attacking:
		velocity.x += direction.x * SPEED
		if abs(velocity.x) > SPEED:
			velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*0.65)
	
	if direction.x >0 and is_flipped:
		change_player_direction()
	elif direction.x < 0 and not is_flipped:
		change_player_direction()
	
	animation_tree.set("parameters/Moviment/blend_position", direction.x)
	
	velocity.z = 0.0
	#print("vel x:", velocity.x)
	move_and_slide()
	pass

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
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_throw") and not is_attacking  and current_spear != null:
		throw_spear()
	pass


func throw_spear()->void:
	is_attacking = true
	if not is_on_floor(): 
		state_machine.travel("AirThrow")
	else:
		state_machine.travel("Throw")
	pass


func shoot_spear()->void:
	print("spear shooted!")
	if not  current_spear:
		return
	
	var socket = current_spear.get_parent()
	socket.remove_child(current_spear)
	
	
	get_tree().root.add_child(current_spear)
	current_spear.is_throwed(throw_position.global_position, is_flipped)
	#current_spear.global_position = 
	#current_spear.is_flipped = is_flipped
	#current_spear.throwed = true
	current_spear.scale = self.scale
	current_spear.speed = SHOOT_SPEED
	
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
	if anim_name.to_lower().contains("throw"):
		is_attacking = false
	pass # Replace with function body.




func spear_respawn_timeout() -> void:
	reload_spear()
	pass # Replace with function body.
