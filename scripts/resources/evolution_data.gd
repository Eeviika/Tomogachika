## Represents a possible evolution that a species may have.
class_name EvolutionData
extends Resource

## The species that another species will evolve into.
@export var evolution: SpeciesData

@export_category("Conditions")
## If true, this evolution can occur in spring.
@export var in_spring: bool = false
## If true, this evolution can occur in summer.
@export var in_summer: bool = false
## If true, this evolution can occur in fall.
@export var in_fall: bool = false
## If true, this evolution can occur in winter.
@export var in_winter: bool = false
## If true, this evolution can occur at day.
@export var at_day: bool = false
## If true, this evolution can occur at night.
@export var at_night: bool = false
## The amount of happiness the pet must have to evolve.
## 0 means it can evolve at any amount of happiness.
@export var required_happiness: float = 0.0
## The age the pet must reach to evolve.
## This is measured in days.
@export var required_age: int = 0
