extends Area2D

signal plat_pret(plat)

var player_nearby = false  
var ingredient_plats = []  # Liste des ingrédients nécessaires pour le plat sélectionné
var plat_selectionne = null  
var cuisson = preload("res://cuisson/cuisson.tscn")  
const API_URL = "https://m-esakafo-1.onrender.com/api/commandes/attente"  
const PlatScene = preload("res://plats/plat.tscn")  
var ingredient_trouve = null
@onready var temps = $"../StaticBody2D/etat de cuisson"
@onready var goblin = get_node("/root/Main/Goblin")
@onready var recettes = get_node("/root/Main/Recette")  
@onready var http_request = HTTPRequest.new()  
@onready var refresh_timer = Timer.new()  
@onready var cuisson_manager = get_node("/root/CuissonManager")  

var timer_cuisson = null  
var temps_restant = 0.0  

func _ready():
	add_child(http_request)  
	http_request.request(API_URL)  
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))

	add_child(refresh_timer)
	refresh_timer.wait_time = 2.0  # Mettre à jour toutes les 2 secondes
	refresh_timer.connect("timeout", Callable(self, "actualiser_plats"))
	refresh_timer.start()
	#actualiser_plats()

func _on_body_entered(body):
	if body is Goblin:  # Vérifie si c'est le joueur
		player_nearby = true

func _on_body_exited(body):
	if body is Goblin:
		player_nearby = false

func _process(delta):
	if player_nearby and Input.is_action_just_pressed("interact"):
		#print("Interaction avec le feu.")
		selectionner_plat()
	if player_nearby and Input.is_action_just_pressed("grab"):

		if goblin.food_info != null:
			print("depot d'ingredient :", goblin.food_info["nom"])
			verifier_ingredient_ajoute(goblin.food_info)
		else:
			print("Aucun ingredient entre les mains")

	if timer_cuisson and temps_restant > 0:
		temps_restant -= delta
		temps.text = "Temps restant : %.1f s" % temps_restant

# Sélectionne un plat à cuire
func selectionner_plat():
	if cuisson_manager.plats_a_preparer.size() == 0:
		print("Aucun plat à préparer.")
		return

	if plat_selectionne:
		print("Un plat est déjà en cours de cuisson :", plat_selectionne["plat"]["nom"])
		return

	for plat in cuisson_manager.plats_a_preparer:
		var plat_id = int(plat["plat"]["id"])

		if cuisson_manager.est_plat_cuit(plat_id):
			print("Plat déjà cuit :", plat["plat"]["nom"])
			continue  # Ignore les plats déjà cuits

		plat_selectionne = plat
		print("Plat sélectionné :", plat_selectionne["id"])

		# Récupérer les ingrédients nécessaires pour ce plat
		ingredient_plats.clear()
		for ingredientrecette in recettes.recette_recup:
			if ingredientrecette["plat"]["id"] == plat_selectionne["plat"]["id"]:
				ingredient_plats.append(ingredientrecette)
		cuisson_manager.plats_a_preparer.erase(plat_selectionne)  # Retirer le plat de la liste
		print("Ingrédients nécessaires :", ingredient_plats)
		return

	print("Aucun plat disponible pour la cuisson.")

# Lorsqu'un plat est sélectionné pour la cuisson
func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		var data = json.get_data()

		if parse_result == OK and typeof(data) == TYPE_ARRAY:
			var nouveaux_plats = []

			# Vérification de chaque plat
			for plat in data:
				var id_plat = int(plat["plat"]["id"])
				ajouter_plats_a_preparer(nouveaux_plats, plat)

func ajouter_plats_a_preparer(nouveaux_plats, plat):
	var plat_id = int(plat["plat"]["id"])

	# Ignore les plats déjà cuits
	if cuisson_manager.est_plat_cuit(plat_id):
		#print("Plat déjà cuit, ignoré :", plat.get("nom", ""))
		return

	# Vérifie si le plat est déjà dans la liste avant de l'ajouter
	if not cuisson_manager.plats_a_preparer.has(plat):
		cuisson_manager.ajouter_plat_a_preparer(plat)
		nouveaux_plats.append(plat)
	#else:
		#print("Plat déjà présent, ignoré :", plat.get("nom", ""))

	# Tri des nouveaux plats par ID
	nouveaux_plats.sort_custom(func(a, b): return int(a["plat"]["id"]) < int(b["plat"]["id"]))


# Vérifie si un ingrédient est ajouté au feu
func verifier_ingredient_ajoute(ingredient_info):
	if plat_selectionne == null:
		print("Aucun plat sélectionné pour la cuisson.")
		return

	# Vérifier si l'ingrédient est dans la recette du plat
	var index = 0
	for i in ingredient_plats:
		if i["ingredient"]["id"] == ingredient_info["id"]:
			ingredient_trouve = i
			break
		index+=1

	if ingredient_trouve != null:
		print("Ingrédient ajouté :", ingredient_trouve["ingredient"]["nom"])
		ingredient_plats.remove_at(index)  # Retirer l'ingrédient de la liste
		print("Ingrédients restants :", ingredient_plats)

		# Si tous les ingrédients sont réunis, lancer la cuisson
		if ingredient_plats.size() == 0:
			commencer_cuisson()
	else:
		print("ingredient invalide, veillez le jeter")

# Débute la cuisson lorsque tous les ingrédients sont réunis
func commencer_cuisson():
	if plat_selectionne:
		# Récupérer le temps de cuisson depuis l'API ou une valeur par défaut
		temps_restant = Utiles.format_time(plat_selectionne["plat"].get("tempsCuisson", ""))
		timer_cuisson = get_tree().create_timer(temps_restant)
		print("Début de la cuisson de", plat_selectionne["plat"]["nom"])
		
		await timer_cuisson.timeout  # Attendre la fin du timer
		
		# Création du plat fini
		var plat_cuit = load("res://plats/plat_finie.tscn").instantiate()
		plat_cuit.id_plat = plat_selectionne["id"]  # Assigner l'ID du plat cuit
		
		# Placer le plat sur le feu
		#var feu_position = $Feu_1.global_position  # Récupérer la position du feu
		#plat_cuit.global_position = feu_position

		# Ajouter la scène au parent (la cuisine ou la map)
		get_parent().add_child(plat_cuit)
		
		print("Plat cuit :", plat_selectionne["plat"]["nom"], " placé sur le feu !")

		# Réinitialisation des variables
		plat_selectionne = null
		temps_restant = 0
		timer_cuisson = null
		
		# Émettre un signal avec le plat
		plat_pret.emit(plat_cuit)


# Fonction désactivée mais conservée pour référence
# func _on_request_completed(result, response_code, headers, body):
#     var json = JSON.parse(body.get_string_from_utf8())
#     print("Données API reçues :", json.result)

#func actualiser_plats():
	#print("Food info :", goblin.food_info)
	#print("recettes :", recettes.recette_recup)
	# Actualisation de la liste des plats depuis CuissonManager
	#http_request.request(API_URL)
	#print(cuisson_manager.plats_deja_cuits_global)
	#print(cuisson_manager.plats_a_preparer)
