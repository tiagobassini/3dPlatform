extends Node3D

@onready var gridmap: GridMap = $GridMap

const DIRECOES = [
	Vector3i(1, 0, 0),
	Vector3i(-1, 0, 0),
	Vector3i(0, 1, 0),
	Vector3i(0, -1, 0),
	Vector3i(0, 0, 1),
	Vector3i(0, 0, -1),
]

func _ready():
	gerar_colisoes_visiveis()

func gerar_colisoes_visiveis():
	var usadas = gridmap.get_used_cells()
	
	# Cria um dicionário para acesso rápido
	var usadas_set := {}
	for cell in usadas:
		usadas_set[cell] = true

	var contador = 0

	for cell in usadas:
		var cercado = true
		for dir in DIRECOES:
			if not usadas_set.has(cell + dir):
				cercado = false
				break
		if cercado:
			continue

		var mesh = gridmap.mesh_library.get_item_mesh(gridmap.get_cell_item(cell))
		if not mesh:
			continue

		var aabb = mesh.get_aabb()
		var corpo = StaticBody3D.new()
		var colisor = CollisionShape3D.new()
		colisor.shape = BoxShape3D.new()
		colisor.shape.size = aabb.size
		corpo.add_child(colisor)

		# ✅ Copia layers e masks do GridMap
		corpo.collision_layer = gridmap.collision_layer
		corpo.collision_mask = gridmap.collision_mask

		corpo.position = gridmap.map_to_local(cell) + aabb.position + aabb.size * 0.5
		add_child(corpo)

		contador += 1

	print("✅ Colisões geradas:", contador)
