extends Node

var assets = {
	"llave": preload("res://assets/tscn/llave.tscn")
}

func getAsset(name: String) -> PackedScene:
	return assets.get(name.to_lower(), null)
