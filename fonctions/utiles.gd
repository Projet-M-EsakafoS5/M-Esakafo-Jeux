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
	
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Commande mise à jour avec succès !")
	else:
		print("Échec de la mise à jour. Code :", response_code, " Réponse :", body.get_string_from_utf8())

func update_commande_status(plat_id, statut):
	var url = "https://m-esakafo-1.onrender.com/api/commandes/%s/statut" % str(plat_id)  # Remplace le 1 par l'ID du plat
	var http_request = HTTPRequest.new()
	add_child(http_request)  # Ajoute le HTTPRequest comme enfant

	http_request.request_completed.connect(_on_request_completed)  # Connecte le signal pour récupérer la réponse

	var headers = ["Content-Type: application/json"]
	var data = JSON.stringify({"statut": statut})  # Convertit les données en JSON

	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, data)

	if error != OK:
		print("Erreur lors de la requête PATCH :", error)
