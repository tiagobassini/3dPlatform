extends Node3D

@onready var ground_sensor: Node3D = $GroundSensor

@onready var spikes: Node3D = $Spikes

@onready var spike_1: Node3D = $Spikes/Spike1
@onready var spike_2: Node3D = $Spikes/Spike2
@onready var spike_3: Node3D = $Spikes/Spike3
@onready var spike_4: Node3D = $Spikes/Spike4
@onready var spike_5: Node3D = $Spikes/Spike5
@onready var spike_6: Node3D = $Spikes/Spike6

var passed: bool = false



#@onready var spikes: Array[Node3D] = [spike_1, spike_2, spike_3, spike_4, spike_5, spike_6]
#@onready var spikes: Array[Node3D] = []

var spikes_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spikes.get_children()
	#_verify_ground_size()
	#_set_spikes_visibility()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not passed:
		passed = true
		print("start")
		_verify_ground_size()
		#_set_spikes_visibility()
	pass



func _verify_ground_size()->void:
	
	var sensores:Array = ground_sensor.get_children()
	for sensor:RayCast3D in sensores :
		await get_tree().process_frame
		if not sensor.is_colliding():
			print("i: ", spikes_count , " não colidiu")
			break
		spikes_count+=1
	pass


func _set_spikes_visibility()->void:
	
	var i:int = 0
	
	while i<spikes_count:
		spikes.get_child(i).show()
	pass
