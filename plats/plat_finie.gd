extends Node2D  # (ou StaticBody2D selon ton cas)

var id_plat = null  # ID du plat cuisiné

func _ready():
	if id_plat != null:
		print("Plat prêt à être ramassé, ID :", id_plat)

func _on_body_entered(body):
	if body is Goblin:  # Vérifie si le gobelin est à proximité
		body.recuperer_plat_cuit(self)  # Appelle la fonction de ramassage
