local blockableGroups = { 
	-- List of {entity_type, default_block_distance}.
	-- In the future, this could also allow entries like {filter_list, default_block_distance, default_block_count, setting_name}.
	-- TODO modify this to allow for general filters, with specified setting name.
	--   For example we should be able to consider types {"ammo-turret", "electric-turret", "fluid-turret"} together, with one name and one setting.
	--   Or for example we should be able to consider {{type = "lamp"}, {type = "assembling-machine", name = "deadlock-copper-lamp"}} together.

	{"inserter", 300},
	{"assembling-machine", 300},
		-- currently includes stuff like lamps from Industrial Revolution 3, TODO separate out by using finer-grained filters.
	{"electric-pole", 300},
	{"furnace", 300},
	{"ammo-turret", 300}, {"electric-turret", 300}, {"fluid-turret", 300}, {"artillery-turret", 300},
		-- TODO add a group for all of these together.

	{"solar-panel", 300},
	{"accumulator", 300},
	{"generator", 300}, -- steam engines and steam turbines
	{"boiler", 300},
	--{"reactor", 300},

	{"storage-tank", 300},
	{"container", 300}, {"logistic-container", 300},
		-- TODO put these in one filter group

	{"lab", 300},

	{"mining-drill", 300},
		-- currently includes pumpjacks, TODO separate out by using finer-grained filters.

	--{"pump", 300},
	--{"offshore-pump", 300},

	{"lamp", 300},
		-- TODO add filters to include copper lamp from Larger Lamps and the lamps from Industrial Revolution 3

	{"beacon", 300},

	--{"train-stop", 300},
	--{"rail-signal", 300}, {"rail-chain-signal", 300},
		-- TODO put these in one filter group
	--{"roboport", 300},

	--{"arithmetic-combinator", 300}, {"constant-combinator", 300}, {"decider-combinator", 300},
		-- TODO put these in one filter group
	--{"power-switch", 300},

	--{"radar", 300},
	--{"rocket-silo", 300},

	{"splitter", 300},
	--{"transport-belt", 0}, -- Might make sense when count=4 is implemented; currently with count=3 they're useless. Could also take the rotation into account.
	--{"pipe", 0}, -- Might make sense when count=4 is implemented.
	{"underground-belt", 0}, -- Bug: flips direction when placed and removed.
	{"pipe-to-ground", 0}, -- Bug: flips direction when placed and removed.
}
return blockableGroups

-- TODO add a setting where users can supply a comma-separated string that adds new blockable groups, including adding new startup settings for those groups.