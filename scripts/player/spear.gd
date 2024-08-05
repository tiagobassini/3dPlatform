extends Node3D
class_name Spear


@export var speed: float = 5.5
var throwed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if throwed:
		if rotation_degrees.z <0 :
			global_position.x += speed*delta
		else:
			global_position.x -= speed*delta
