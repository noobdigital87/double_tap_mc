local your_mod_name = core.get_current_modname()

local api = dg_sprint_core -- luacheck: ignore

local settings = {
	aux1 = true,
	double_tap = true,
	tap_interval = tonumber(core.settings:get(your_mod_name .. ".tap_interval")) or 0.5,
	detection_step = tonumber(core.settings:get(your_mod_name .. ".detection_step")) or 0.1,
	sprint_step = tonumber(core.settings:get(your_mod_name .. ".sprint_step")) or 0.2,
	drain_step = tonumber(core.settings:get(your_mod_name .. ".drain_step")) or 0.2,
}

mcl_sprint.SPEED = tonumber(core.settings:get(your_mod_name .. ".set_speed")) or 1.8 -- luacheck: ignore

api.register_server_step(your_mod_name, "DETECT", settings.detection_step , function(player, state)

	local control = player:get_player_control()
	local use_aux = (settings.aux1 and control.aux1)
	local use_double_tap = (settings.double_tap and control.up)
	local is_starving =  (mcl_hunger.get_hunger(player) <= 6) -- luacheck: ignore

	local detected = api.sprint_key_detected(player, use_aux, use_double_tap , settings.tap_interval) and not is_starving
	if detected ~= state.detected then
		state.detected = detected
	end

end)

api.register_server_step(your_mod_name, "SPRINT", settings.sprint_step , function(player, state)

    if not settings.fov then
        settings.fov_value = 0
    end

    if state.detected then
        local sprint_settings = {speed = settings.speed, jump = settings.jump}
	local pos = player:get_pos()
        api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
        local playerNode = core.get_node({x=pos.x, y=pos.y-1, z=pos.z})
	local def = core.registered_nodes[playerNode.name]
		if def and def.walkable then
			core.add_particlespawner({
				amount = math.random(1, 2),
					time = 1,
					minpos = {x=-0.5, y=0.1, z=-0.5},
					maxpos = {x=0.5, y=0.1, z=0.5},
					minvel = {x=0, y=5, z=0},
					maxvel = {x=0, y=5, z=0},
					minacc = {x=0, y=-13, z=0},
					maxacc = {x=0, y=-13, z=0},
					minexptime = 0.1,
					maxexptime = 1,
					minsize = 0.5,
					maxsize = 1.5,
					collisiondetection = true,
					attached = player,
					vertical = false,
					node = playerNode,
					node_tile = mcl_sprint.get_top_node_tile(playerNode.param2, def.paramtype2), -- luacheck: ignore
				})
			end
    else
        local sprint_settings = {speed = settings.speed, jump = settings.jump}
        api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
    end
end)

api.register_server_step(your_mod_name, "DRAIN", settings.drain_step, function(player, state)
	if state.detected and api.is_player_draining(player) then
		mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_SPRINT) -- luacheck: ignore
	end
end)
