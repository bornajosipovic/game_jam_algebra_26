extends Node

enum UpgradeRarity { GENERAL, CLASS_SPECIFIC, CLASS_MASTER }

var upgrades = [
	{ "id": "gen_speed", "name": "Brzina +5%", "rarity": UpgradeRarity.GENERAL, "class": null, "stat": "speed", "value": 0.05 },
	{ "id": "gen_dmg", "name": "DMG +5%", "rarity": UpgradeRarity.GENERAL, "class": null, "stat": "dmg", "value": 0.05 },
	{ "id": "gen_range", "name": "Item Range +5%", "rarity": UpgradeRarity.GENERAL, "class": null, "stat": "range", "value": 0.05 },
	{ "id": "gen_cooldown", "name": "Cooldown -10%", "rarity": UpgradeRarity.GENERAL, "class": null, "stat": "cooldown", "value": -0.10 },
	{ "id": "gen_timer", "name": "Timer +1s", "rarity": UpgradeRarity.GENERAL, "class": null, "stat": "timer", "value": 1.0 },

	{ "id": "kn_speed", "name": "Vitez: Brzina +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.KNIGHT, "stat": "speed", "value": 0.12 },
	{ "id": "kn_dmg", "name": "Vitez: DMG +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.KNIGHT, "stat": "dmg", "value": 0.12 },
	{ "id": "kn_range", "name": "Vitez: Item Range +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.KNIGHT, "stat": "range", "value": 0.12 },
	{ "id": "kn_cooldown", "name": "Vitez: Cooldown -20%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.KNIGHT, "stat": "cooldown", "value": -0.20 },
	{ "id": "kn_timer", "name": "Vitez: Timer +3s", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.KNIGHT, "stat": "timer", "value": 3.0 },

	{ "id": "pr_speed", "name": "Svecenik: Brzina +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.PRIEST, "stat": "speed", "value": 0.12 },
	{ "id": "pr_dmg", "name": "Svecenik: DMG +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.PRIEST, "stat": "dmg", "value": 0.12 },
	{ "id": "pr_range", "name": "Svecenik: Item Range +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.PRIEST, "stat": "range", "value": 0.12 },
	{ "id": "pr_cooldown", "name": "Svecenik: Cooldown -20%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.PRIEST, "stat": "cooldown", "value": -0.20 },
	{ "id": "pr_timer", "name": "Svecenik: Timer +3s", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.PRIEST, "stat": "timer", "value": 3.0 },

	{ "id": "ra_speed", "name": "Stakor: Brzina +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.RAT, "stat": "speed", "value": 0.12 },
	{ "id": "ra_dmg", "name": "Stakor: DMG +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.RAT, "stat": "dmg", "value": 0.12 },
	{ "id": "ra_range", "name": "Stakor: Item Range +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.RAT, "stat": "range", "value": 0.12 },
	{ "id": "ra_cooldown", "name": "Stakor: Cooldown -20%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.RAT, "stat": "cooldown", "value": -0.20 },
	{ "id": "ra_timer", "name": "Stakor: Timer +3s", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.RAT, "stat": "timer", "value": 3.0 },

	{ "id": "ch_speed", "name": "Dijete: Brzina +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "speed", "value": 0.12 },
	{ "id": "ch_armor", "name": "Dijete: Oklop +10%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "armor", "value": -0.10 },
	{ "id": "ch_dmg", "name": "Dijete: DMG +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "dmg", "value": 0.12 },
	{ "id": "ch_range", "name": "Dijete: Item Range +12%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "range", "value": 0.12 },
	{ "id": "ch_cooldown", "name": "Dijete: Cooldown -20%", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "cooldown", "value": -0.20 },
	{ "id": "ch_timer", "name": "Di	jete: Timer +3s", "rarity": UpgradeRarity.CLASS_SPECIFIC, "class": GameManager.PlayerClass.CHILD, "stat": "timer", "value": 3.0 },

	{ "id": "cm_knight", "name": "Vitez Master: Veci Range", "rarity": UpgradeRarity.CLASS_MASTER, "class": GameManager.PlayerClass.KNIGHT, "stat": "master", "value": 0 },
	{ "id": "cm_priest", "name": "Svecenik Master: Freeze", "rarity": UpgradeRarity.CLASS_MASTER, "class": GameManager.PlayerClass.PRIEST, "stat": "master", "value": 0 },
	{ "id": "cm_child", "name": "Dijete Master: 2 Dasha", "rarity": UpgradeRarity.CLASS_MASTER, "class": GameManager.PlayerClass.CHILD, "stat": "master", "value": 0 },
	{ "id": "cm_rat", "name": "Stakor Master: Frenzy Kill", "rarity": UpgradeRarity.CLASS_MASTER, "class": GameManager.PlayerClass.RAT, "stat": "master", "value": 0 },
]

var active_upgrades: Array = []

func get_random_upgrades(count: int = 3) -> Array:
	var pool = []
	for upgrade in upgrades:
		if has_upgrade(upgrade["id"]):
			continue
		match upgrade["rarity"]:
			UpgradeRarity.GENERAL:
				for i in 12: pool.append(upgrade)
			UpgradeRarity.CLASS_SPECIFIC:
				for i in 6: pool.append(upgrade)
			UpgradeRarity.CLASS_MASTER:
				for i in 1: pool.append(upgrade)
	pool.shuffle()
	var result = []
	var seen_ids = []
	for upgrade in pool:
		if upgrade["id"] not in seen_ids:
			result.append(upgrade)
			seen_ids.append(upgrade["id"])
		if result.size() == count:
			break
	return result

func apply_upgrade(upgrade: Dictionary) -> void:
	active_upgrades.append(upgrade)
	GameManager.upgrade_selected.emit(upgrade)

func has_upgrade(upgrade_id: String) -> bool:
	for upgrade in active_upgrades:
		if upgrade["id"] == upgrade_id:
			return true
	return false

func get_active_upgrades_for_class(player_class) -> Array:
	var result = []
	for upgrade in active_upgrades:
		if upgrade["class"] == null or upgrade["class"] == player_class:
			result.append(upgrade)
	return result
