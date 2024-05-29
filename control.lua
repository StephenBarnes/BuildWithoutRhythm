
local blockableGroups = require("blockable-groups")
local blockableGroupsSet = {}
for _, v in pairs(blockableGroups) do
	blockableGroupsSet[v[1]] = true
end

local lastMessageTick = 0
local messageWaitTicks = 15 -- Don't show message if a message was already shown within this many ticks ago.

local function posEqual(p1, p2)
	return p1.x == p2.x and p1.y == p2.y
end

local function length(v)
	return math.floor(math.sqrt(v.x * v.x + v.y * v.y))
end

local function findBlockingEntity(ent1, rad)
	-- If the given entity completes an arithmetic trio, this returns one of the other entities in that trio.
	-- If given entity is an endpoint, it always returns the closer of the two other entities.
	-- If multiple trios, can return any of them.
	-- If no trio, returns nil.
	local pos1 = ent1.position
	local nearbyEnts = ent1.surface.find_entities_filtered {
		position = pos1,
		radius = rad / 2,
			-- Divide by 2, because if there's a 3rd entity within distance rad, then there must be a 2nd entity within rad/2.
			-- This reduces search radius and also always returns the nearer blocking entity, in the endpoint case.
		type = ent1.type,
	}
	for _, ent2 in pairs(nearbyEnts) do
		local pos2 = ent2.position
		if not posEqual(pos2, pos1) then
			-- There's two cases we need to block.
			-- The endpoint case: Our new entity is one of the ends of a trio.
			-- The midpoint case: Our new entity is the center of a trio.

			local pos3EndpointCase = {
				x = pos2.x * 2 - pos1.x,
				y = pos2.y * 2 - pos1.y,
			}
			local ent3EndpointCase = ent1.surface.find_entities_filtered {
				position = pos3EndpointCase,
				type = ent1.type,
				limit = 1,
			}
			if #ent3EndpointCase == 1 then
				-- For multi-tile entities, find_entities will sometimes return an entity that overlaps with where we searched, but has its center elsewhere.
				-- We don't want to block in that case, so we need this extra check.
				if posEqual(ent3EndpointCase[1].position, pos3EndpointCase) then
					return ent2
				end
			end

			local pos3MidpointCase = {
				x = pos1.x * 2 - pos2.x,
				y = pos1.y * 2 - pos2.y,
			}
			local ent3MidpointCase = ent1.surface.find_entities_filtered {
				position = pos3MidpointCase,
				type = ent1.type,
				limit = 1,
			}
			if #ent3MidpointCase == 1 then
				if posEqual(ent3MidpointCase[1].position, pos3MidpointCase) then
					return ent2
				end
			end
		end
	end
	return nil
end

local function getRelativePosString(a, b)
	-- Given positions a, b, makes a string describing the position of b relative to A, like "25 E" meaning 25 blocks east.
	local d = {x = b.x - a.x, y = b.y - a.y}
	local distance = length(d)

	local angle = math.atan2(d.y, d.x) -- Returns angle in radians
		-- Note Factorio is on an old version of Lua so you need math.atan2 instead of math.atan.
	-- From testing: Down is 1.57, up is -1.57, left is 3.14, right is 0.
	-- We have 8 compass directions, so each one's range has length 2pi/8.
	local dir = nil
	if angle > 2.748 then
		dir = "W"
	elseif angle > 1.963 then
		dir = "SW"
	elseif angle > 1.178 then
		dir = "S"
	elseif angle > 0.393 then
		dir = "SE"
	elseif angle > -0.393 then
		dir = "E"
	elseif angle > -1.178 then
		dir = "NE"
	elseif angle > -1.963 then
		dir = "N"
	elseif angle > -2.749 then
		dir = "NW"
	else
		dir = "W"
	end
	return distance .. " " .. dir
end

local function maybeBlockPlayerPlacement(event)
	local entityType = event.created_entity.type
	if not blockableGroupsSet[entityType] then return end
	local settingName = "BuildWithoutRhythm-block-"..entityType
	local radius = settings.global[settingName].value
	if radius == 0 then return end

	local placed = event.created_entity
	local blockedBy = findBlockingEntity(placed, radius)
	if blockedBy == nil then return end

	local player = game.get_player(event.player_index)
	if player == nil then
		log("Player is nil")
		return
	end
	if game.tick > lastMessageTick + messageWaitTicks then
		lastMessageTick = game.tick
		local relativePosString = getRelativePosString(placed.position, blockedBy.position)
		player.create_local_flying_text {
			text = {"cant-build-reason.entity-forms-trio", {"entity-name."..blockedBy.name}, relativePosString},
			create_at_cursor = true,
			time_to_live = 120,
		}
	end
	player.mine_entity(placed, true) -- "true" says force mining it even if player's inventory is full.
end

local function maybeBlockRobotPlacement(event)
	local entityType = event.created_entity.type
	if not blockableGroupsSet[entityType] then return end
	local settingName = "BuildWithoutRhythm-block-"..entityType
	local radius = settings.global[settingName].value
	if radius == 0 then return end

	local placed = event.created_entity
	local blockedBy = findBlockingEntity(placed, radius)
	if blockedBy == nil then return end

	local surface = placed.surface
	local pos = placed.position
	placed.destroy()
	surface.spill_item_stack(pos, event.stack, nil, event.robot.force)
		-- Force arg is to mark the spilled item stack for deconstruction by the robot's force.
end

script.on_event(defines.events.on_built_entity, maybeBlockPlayerPlacement)
script.on_event(defines.events.on_robot_built_entity, maybeBlockRobotPlacement)

-- TODO: Add settings to adjust how many in a straight line before we block it. Could be better to set that to like 4, rather than 3. Shouldn't be too hard to implement.