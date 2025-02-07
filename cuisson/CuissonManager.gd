extends Node

var plats_a_preparer = []  # Liste des plats à préparer (partagée entre tous les feux)
var plats_deja_cuits_global = {}  # Liste des plats déjà cuits
var plats_a_preparer_temp = []  # Liste temporaire pour le traitement des nouveaux plats

# Fonction pour ajouter un plat cuit
func ajouter_plat_cuit(plat_id):
	plats_deja_cuits_global[plat_id] = true

# Fonction pour vérifier si un plat est déjà cuit
func est_plat_cuit(plat_id):
	return plats_deja_cuits_global.has(plat_id)

# Ajouter un plat à la liste des plats à préparer
func ajouter_plat_a_preparer(plat):
	if not plats_a_preparer.has(plat):  # Vérifie s'il n'est pas déjà dans la liste
		plats_a_preparer.append(plat)
		plats_a_preparer.sort_custom(func(a, b): return int(a["plat"]["id"]) < int(b["plat"]["id"]))
