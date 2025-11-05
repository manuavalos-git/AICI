extends Node

var assets = {
	"llave": preload("res://assets/tscn/llave.tscn"),
	"fresadora": preload("res://assets/tscn/fresadora.tscn"),
	"valvula": preload ("res://assets/tscn/valvula.tscn")
}

func getAsset(name: String) -> PackedScene:
	return assets.get(name.to_lower(), null)
