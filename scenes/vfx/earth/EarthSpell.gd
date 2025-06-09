extends Node3D

@onready var ground_sensor: Node3D = $GroundSensor

@onready var spikes: Node3D = $Spikes

var passed: bool = false



#@onready var spikes: Array[Node3D] = [spike_1, spike_2, spike_3, spike_4, spike_5, spike_6]
#@onready var spikes: Array[Node3D] = []

var spikes_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_verify_ground_size()
	pass




func _verify_ground_size()->void:
	var end_ground = false
	var sensores:Array = ground_sensor.get_children()
	for sensor:RayCast3D in sensores :
		await get_tree().process_frame
		if not sensor.is_colliding():
			print("i: ", spikes_count , " não colidiu")
			end_ground = true
		
		if end_ground :
			var spike: Node3D = spikes.get_child(spikes_count)
			spike.hide()
			for child in spike.get_children():
				child.queue_free()
		else:
			print("i: ", spikes_count , " colidiu")
			spikes.get_child(spikes_count).show()
			print("spike ",spikes_count, ": ",spikes.get_child(spikes_count).name, " foi exibido")
		spikes_count+=1
		
	pass

