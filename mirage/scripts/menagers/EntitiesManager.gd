extends Node
#questo script si deve occupare delle interazioni tra entita come il letto e il player e gli NPC
#QUESTO PERCHE LE SCENE NON DEVONO INTERAGIRE TRA LORO, tutte le logiche che non sono mediante UI o interfaccia 

#----------------------------------------
#----------interazioni letto-------------
#----------------------------------------

# ristora sonno
func bed_sleep_restore(sleep_point :int , npc_id : String) -> void:
	 var human : HumansInfo = HumansManager.get
	
