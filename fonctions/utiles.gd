class_name Utiles extends Node
	
# Convertit "HH:MM:SS" en nombre total de secondes
static func format_time(time_str: String) -> int:
	var parts = time_str.split(":")
	var h = 0
	var m = 0
	var s = 0

	if parts.size() == 3:
		h = int(parts[0])
		m = int(parts[1])
		s = int(parts[2])

	return (h * 3600) + (m * 60) + s
	
