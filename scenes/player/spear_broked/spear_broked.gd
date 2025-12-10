extends Node3D

@onready var part_1: RigidBody3D = $Parts/Part1
@onready var part_2: RigidBody3D = $Parts/Part2
@onready var part_3: RigidBody3D = $Parts/Part3


func broken()->void:
	part_1.apply_impulse(Vector3(2,50,0))
	part_2.apply_impulse(Vector3(5,50,0))
	part_3.apply_impulse(Vector3(8,50,0))
