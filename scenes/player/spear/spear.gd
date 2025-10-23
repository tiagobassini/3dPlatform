extends Node3D
class_name Spear


@onready var blade_area: Area3D = $BladeArea
@onready var spring_area: Area3D = $SpringArea
@onready var shaft_body_collision: CollisionShape3D = $ShaftBody/CollisionShape3D
@onready var shaft_area_detector: Area3D = $ShaftAreaDetector
@onready var timer: Timer = $Timer
@onready var spell_socket: Node3D = $Armature/Skeleton3D/BoneAttachment3D/SpellSocket

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 5.5
@export var fixed_time: float = 2.5
@export var spring_force: float = 5.0

@export var spell: PackedScene


var player: Player = null
var throwed: bool = false
var spring: bool = false

var is_flipped: bool = false :
	get : return is_flipped
	set (value):
		is_flipped = value
		set_flipped()



func set_flipped()->void:
	if not is_flipped:
		global_rotation_degrees = Vector3(0, 0, -90.0)
	else:
		global_rotation_degrees = Vector3(0, 180, -90.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if throwed:
		if not is_flipped :
			global_position.x += speed*delta
		else:
			global_position.x -= speed*delta
	elif player != null :
		if global_position.y <= player.global_position.y:
			shaft_body_collision.disabled = false
		elif not spring:
			shaft_body_collision.disabled = true
	



func is_throwed(throw_position:Vector3, flipped: bool)->void:
	
	throwed = true
	is_flipped = flipped
	global_position = throw_position
	blade_area.set_deferred("monitoring", true)
	blade_area.set_deferred("monitorable", true)
	


func _on_blade_and_body_collided(_body: Node3D) -> void:
	print("collided")
	throwed = false
	blade_area.set_deferred("monitoring", false)
	blade_area.set_deferred("monitorable", false)
	
	spring_area.set_deferred("monitoring", true)
	spring_area.set_deferred("monitorable", true)
	
	shaft_area_detector.set_deferred("monitoring", true)
	shaft_area_detector.set_deferred("monitorable", true)
	
	animation_player.play("collided")
	
	timer.start(fixed_time)
		
	call_spell()





func _on_shaft_area_detector(body: Node3D) -> void:
	if body as Player:
		player = body
		if (body.global_position.y +0.1) >= global_position.y :
			shaft_body_collision.set_deferred("disabled", false)



func _on_shaft_area_detector_body_exited(body: Node3D) -> void:
	if body as Player:
		player = null
		shaft_body_collision.set_deferred("disabled", true)


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_spring_area_body_entered(body: Node3D) -> void:
	if body as Player:
		spring = true
		print("play spring")
		animation_player.stop()
		animation_player.play("spring")
		
	pass # Replace with function body.


func launch_player()->void:
	if player!=null:
		if Input.is_action_pressed("ui_jump"):
			player.velocity.y = 1.5 * spring_force
		else:
			player.velocity.y = spring_force
	pass
	


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spring":
		spring= false
	pass # Replace with function body.


func call_spell()->void:
	
	if spell != null :
		var spell_instance: Node3D = spell.instantiate()
		get_tree().root.add_child(spell_instance)
		spell_instance.global_position = spell_socket.global_position
	
	pass
