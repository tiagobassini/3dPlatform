extends Node3D




func _on_area_3d_body_entered(body: Node3D) -> void:
	if body as Player:
		get_tree().call_deferred("reload_current_scene")
	pass # Replace with function body.
