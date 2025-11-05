# Catálogo de Assets Industriales 3D
# Este archivo define los objetos que se pueden invocar en el simulador

## Formato de Comandos
# "mostrar [nombre]" o "ver [nombre]"

## Assets Disponibles

### Herramientas Manuales
- llave inglesa, llave ajustable
- destornillador plano, destornillador phillips
- martillo, mazo
- alicate, pinza
- llave de tubo, llave allen

### Maquinaria Industrial (Futuro)
- bomba centrifuga
- valvula de bola
- motor electrico
- compresor
- reductor

### Componentes Mecánicos (Futuro)
- rodamiento
- engranaje
- polea
- correa
- cadena

### Equipos de Seguridad (Futuro)
- casco
- guantes
- gafas
- señal de seguridad

### Instrumentación (Futuro)
- manometro
- sensor de temperatura
- medidor de flujo
- controlador

## Notas de Implementación
- Actualmente solo la "llave" está implementada con el sistema toggle_sprite
- Para agregar más assets, necesitas:
  1. Importar el modelo 3D (.fbx, .glb, .obj)
  2. Crear una escena .tscn del asset
  3. Agregar lógica en Mundo.gd para instanciar el asset
  4. Actualizar este catálogo

## Sistema de Invocación Propuesto
```gdscript
# En Mundo.gd - Diccionario de assets
var industrial_assets = {
	"llave": "res://assets/tools/wrench.tscn",
	"destornillador": "res://assets/tools/screwdriver.tscn",
	"martillo": "res://assets/tools/hammer.tscn",
	# ... más assets
}

# Función para spawne
ar assets
func spawn_asset(asset_name: String):
	if industrial_assets.has(asset_name):
		var asset_scene = load(industrial_assets[asset_name])
		var asset_instance = asset_scene.instantiate()
		# Posicionar frente a la cámara
		var cam_transform = camera.global_transform
		asset_instance.global_transform.origin = cam_transform.origin + cam_transform.basis.z * -2.0
		add_child(asset_instance)
	else:
		print("Asset no encontrado: ", asset_name)
```
