extends Node3D

@onready var sound_player_1: AudioStreamPlayer = $Sfx/SoundPlayer1

@onready var sfx: Node = $Sfx
@onready var ground_sensor: Node3D = $GroundSensor
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spikes: Node3D = $Spikes

var passed: bool = false

var spikes_count: int = 0
var sound_count: int =0



func _ready() -> void:
	print("spell")
	#_verify_ground_size()
	pass

func _physics_process(_delta: float) -> void:
	
	if not passed:
		passed = true
		_verify_ground_size()
	pass


func _verify_ground_size()->void:
	var end_ground = false
	var sensores:Array = ground_sensor.get_children()
	await get_tree().process_frame
	for sensor:RayCast3D in sensores :
		
		if not sensor.is_colliding():
			print("i: ", spikes_count , " não colidiu")
			end_ground = true
		
		if end_ground :
			var spike: Node3D = spikes.get_child(spikes_count)
			spike.hide()
			#spike.show()
			var stone = spike.get_child(0)
			if stone.name.contains("Stone"):
				stone.get_child(0).queue_free()
			
		else:
			#print("i: ", spikes_count , " colidiu")
			spikes.get_child(spikes_count).show()
			sound_count+=1
			#print("spike ",spikes_count, ": ",spikes.get_child(spikes_count).name, " foi exibido")
		spikes_count+=1
	
	print("inicio da animacao")
	animation_player.play("Init")
	pass



func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.



func play_sound()->void:
	#var players: Array =sfx.get_children()	
	#var sound_player:AudioStreamPlayer = players[spikes_count]
	
	sound_count = sound_count-1
	
	if sound_count>=0:
		print("sound count: ",sound_count)
		var sound_player:AudioStreamPlayer = sfx.get_child(sound_count)
		sound_player.play()
	
	pass
