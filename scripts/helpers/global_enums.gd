## Global enums for the entire game.
class_name GlobalEnums
extends RefCounted

## Represents pet (or entity)'s gender. If set to NONE, they will be genderless.
enum Gender { NONE, MALE, FEMALE }

## Represents a flavor. Anything that uses flavors (other than food) can have more than one flavor assigned.
enum Flavor { SPICY, DRY, SWEET, BITTER, SOUR }

## Represents a pet's mood.
enum Mood {NEUTRAL, HAPPY, HUNGRY, BORED, TIRED, ASLEEP, UPSET, DISAPPOINTED}

enum FoodQuality {POOR, AVERAGE, TASTY, DELICIOUS, GOURMET}

enum CheatCause {TIME_TRAVEL}
