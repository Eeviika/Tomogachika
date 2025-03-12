## Represents a possible evolution that a species may have.
class_name EvolutionData
extends Resource

@export var evolution: SpeciesData

@export_category("Conditions")
@export var in_spring: bool = false
@export var in_summer: bool = false
@export var in_fall: bool = false
@export var in_winter: bool = false
@export var at_day: bool = false
@export var at_night: bool = false
@export var required_happiness: float = 0.0
