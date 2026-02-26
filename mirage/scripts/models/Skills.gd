extends Resource
class_name Skills

var work_room_id : String 
var job : JobManager.job_enum

func _init(_work_room_id: String = "", _job: JobManager.job_enum = JobManager.job_enum.MINATORE) -> void:
	work_room_id = _work_room_id
	job = _job

func to_dict() -> Dictionary:
	# Usiamo la chiave (stringa) invece dell'indice (int) per rendere il file di salvataggio leggibile
	return {
		"work_room_id": work_room_id,
		"job": JobManager.job_enum.keys()[job] 
	}

static func from_dict(d: Dictionary) -> Skills:
	if d.is_empty():
		return Skills.new()

	var room_id = d.get("work_room_id", "")
	var job_string = d.get("job", "MINATORE")
	
	# Convertiamo la stringa nell'indice dell'enum
	# JobManager.job_enum["MINATORE"] restituirà l'intero corretto
	var job_value = JobManager.job_enum.MINATORE # Default
	if job_string in JobManager.job_enum:
		job_value = JobManager.job_enum[job_string]
	
	return Skills.new(room_id, job_value)
