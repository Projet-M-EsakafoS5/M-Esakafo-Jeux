extends Node

var ingredient_recup = []  # Tableau pour stocker les ingrédients récupérés
var request_sent = false  # Variable pour vérifier si la requête a déjà été envoyée

func _ready():
	if request_sent:
		return  # Si la requête a déjà été envoyée, on arrête la fonction

	var url = "https://m-esakafo-1.onrender.com/api/ingredients"
	var http_request = HTTPRequest.new()
	add_child(http_request)  # Ajouter le HTTPRequest au nœud courant
	
	# Connecter le signal avec Callable pour Godot 4
	http_request.request_completed.connect(_on_request_completed)
	
	# Faire la requête GET
	var error = http_request.request(url)
	if error != OK:
		print("Erreur lors de la requête HTTP:", error)

	request_sent = true  # Marquer la requête comme envoyée

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()  # Créer une instance de JSON
		var parse_result = json.parse(body.get_string_from_utf8())  # Parser le JSON
		
		if parse_result == OK:
			var json_data = json.get_data()  # Récupérer les données parsées
			
			if json_data is Dictionary and json_data.has("data"):
				var ingredients = json_data["data"]
				ingredient_recup.clear()  # Nettoyer le tableau avant d'ajouter de nouvelles données
				var position = 100
				for ingredient in ingredients:
					var ingredient_info = {
						"id": int(ingredient["id"]),
						"nom": ingredient["nom"],
						"sprite": ingredient["sprite"],
						"unite_id": int(ingredient["unite"]["id"]),
						"unite_nom": ingredient["unite"]["nom"]
					}

					ingredient_recup.append(ingredient_info)  # Ajouter l'ingrédient au tableau
					spawn_food(ingredient, position)  # Utiliser la position incrémentée
					position = position + 50  # Espacer les ingrédients
				#print("Ingrédients récupérés :", ingredient_recup)

				# Assurer qu'on ne refait pas la requête à nouveau
				request_sent = false  # Réinitialiser le flag si nécessaire pour d'autres usages
			else:
				print("Erreur: Aucune donnée 'data' trouvée dans la réponse JSON.")
		else:
			print("Erreur lors du parsing JSON")
	else:
		print("Erreur de requête HTTP, code:", response_code)

func spawn_food(ingredient, position):
	# Charger la scène principale (Main)
	var main_scene = get_tree().get_root().get_node("Main")  # Assure-toi que le nom du nœud est "Main"
	
	if not main_scene:
		print("Erreur : Impossible de trouver la scène principale 'Main'. Vérifiez si le nœud existe.")
		return
	
	# Charger et instancier l'ingrédient
	var ingredient_scene = load("res://ingredient/ingredient.tscn")
	if not ingredient_scene:
		print("Erreur : Impossible de charger la scène 'ingredient.tscn'. Vérifiez le chemin du fichier.")
		return

	var new_ingredient = ingredient_scene.instantiate()

	# Modifier le Sprite2D pour afficher la bonne image
	var sprite = new_ingredient.get_node("Area2D/Sprite2D")
	if not sprite:
		print("Erreur : Impossible de trouver le Sprite2D dans la scène 'ingredient.tscn'.")
		return

	var texture = load("res://assets/ingredients/" + ingredient["sprite"])
	if texture:
		sprite.texture = texture
		
		# Ajuster l'échelle
		var target_size = Vector2(30, 30)
		var texture_size = texture.get_size()
		sprite.scale = target_size / texture_size
	
	# Positionner l'ingrédient à la position spécifique
	new_ingredient.position = Vector2(position, 100)  # Utiliser la position donnée (ajustable)

	# Ajouter l'ingrédient dans "Main"
	main_scene.add_child(new_ingredient)
