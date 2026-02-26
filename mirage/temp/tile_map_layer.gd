extends TileMapLayer

func _ready():
	# Aspettiamo che la mappa di navigazione sia pronta
	await get_tree().process_frame
	
	# Otteniamo l'ID della mappa di navigazione
	var map = get_world_2d().get_navigation_map()
	# Prendiamo tutte le regioni (strade e prati)
	var regions = NavigationServer2D.map_get_regions(map)
	
	for region in regions:
		# Se questa regione appartiene al layer del "prato" (bit 1, valore 2)
		if NavigationServer2D.region_get_navigation_layers(region) == 2: 
			# Diciamo all'algoritmo che questa zona è "indesiderata"
			NavigationServer2D.region_set_travel_cost(region, 10.0) 
			# Questo non rallenta l'NPC, lo scoraggia solo dal passarci!
