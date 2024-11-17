extends Node3D
class_name Spear



@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 5.5
var throwed: bool = false

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
