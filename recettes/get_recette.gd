extends Node

var recette_recup = []  # Tableau pour stocker les ingrédients récupérés
var request_sent = false  # Variable pour vérifier si la requête a déjà été envoyée

func _ready():
	if request_sent:
		return  # Si la requête a déjà été envoyée, on arrête la fonction

	var url = "https://m-esakafo-1.onrender.com/api/recettes"
	var http_request = HTTPRequest.new()
	add_child(http_request)  # Ajouter le HTTPRequest au nœud courant
	
	# Connecter le signal avec Callable pour Godot 4
	http_request.request_completed.connect(_on_request_completed)
	
	# Faire la requête GET
	var error = http_request.request(url)
	if error != OK:
		print("Erreur lors de la requête HTTP:", error)

	request_sent = true  # Marquer la requête comme envoyée

func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		var data = json.get_data()
		recette_recup = data
