extends Node

signal npc_ready_to_start

#TODO:avviare timer quando piu opportuno
signal timer_start

#TODO:avviare touc quando è avviata la prima mappa di gioco non prima
signal touch

#TODO: avviare salvataggio automatico solo dopo avvio partita
signal save_start

signal roomManager_ready

var savemanager : bool = false:
	set(v): savemanager = v; _check_readiness()

var cameraManager : bool = false:
	set(v): cameraManager = v; _check_readiness()

var humansManager : bool = false:
	set(v): humansManager = v; _check_readiness()

var roomManager : bool = false:
	set(v): roomManager = v; _check_readiness(); _roomanager_ready()
	

# Funzione interna che controlla se tutto è ok
func _check_readiness() -> void:
	D.debug_order("@")
	D.debug("controllo se possibile avviare gli NPC")
	if (savemanager and cameraManager and 
		humansManager and roomManager):
		D.debug("Tutti i sistemi pronti! Invio segnale agli NPC.")
		npc_ready_to_start.emit()
		touch.emit()
		timer_start.emit()
		return
	D.debug("non riuscito")
	
func _roomanager_ready() -> void:
	if roomManager:
		roomManager_ready.emit()
