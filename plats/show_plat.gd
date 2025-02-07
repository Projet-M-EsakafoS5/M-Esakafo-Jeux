extends Control

const PlatScene = preload("res://plats/plat.tscn") # Charger la scène Plat
const API_URL = "https://m-esakafo-1.onrender.com/api/plats"  # Remplace par ton URL

@onready var plats_container = $PlatsContainer

func ajuster_colonnes():
	var nb_plats = plats_container.get_child_count()  # Nombre total de plats ajoutés
	var largeur_ecran = get_viewport().size.x  # Largeur de l’écran
	var largeur_plat = 200  # Largeur moyenne d'un plat (à ajuster selon ton design)

	var colonnes = max(1, largeur_ecran / largeur_plat)  # Calcule le nombre de colonnes possibles
	plats_container.columns = colonnes  # Applique au GridContainer

func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(API_URL)
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))


func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()  # Créer une instance de JSON
		var parse_result = json.parse(body.get_string_from_utf8())  # Parser le JSON

		if parse_result == OK:
			var data = json.get_data()  # Récupérer les données
			if typeof(data) == TYPE_ARRAY:
				for plat in data:
					var plat_instance = PlatScene.instantiate()
					plats_container.add_child(plat_instance)
					var temps_formate = Utiles.format_time(plat.get("tempsCuisson", ""))
					var prix = float(plat.get("prix", "0").replace(",", "."))  # Conversion correcte
					print("Nom: %s, sprite: %s, Temps: %d, Prix: %.2f" %
						  [plat.get("nom", ""), plat.get("sprite", ""), temps_formate, prix])
					plat_instance.set_data(plat["nom"], "res://assets/" + plat["sprite"], temps_formate)
				ajuster_colonnes()
		else:
			print("Erreur de parsing JSON.")
	else:
		print("Erreur HTTP: %d" % response_code)
