local your_mod_name = core.get_current_modname()

local api = dg_sprint_core

local settings = {
    	aux1 = true,
    	double_tap = true,
    	tap_interval = tonumber(core.settings:get(your_mod_name .. ".tap_interval")) or 0.5,
}

mcl_sprint.SPEED = tonumber(core.settings:get(your_mod_name .. ".set_speed")) or 1.8

api.register_server_step(your_mod_name, "DETECT", tonumber(core.settings:get(your_mod_name .. ".detection_step")) or 0.1, function(player, state, dtime)
    local control = player:get_player_control()
		local detected = api.sprint_key_detected(player, (settings.aux1 and control.aux1), (settings.double_tap and control.up), settings.tap_interval) and not (mcl_hunger.get_hunger(player) <= 6)
	if detected ~= state.detected then
		state.detected = detected
	end

end)

api.register_server_step(your_mod_name, "SPRINT", tonumber(core.settings:get(your_mod_name .. ".sprint_step")) or 0.2, function(player, state, dtime)

    if not settings.fov then
        settings.fov_value = 0
    end

    if state.detected then
        local sprint_settings = {speed = settings.speed, jump = settings.jump}
        api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
    else
        local sprint_settings = {speed = settings.speed, jump = settings.jump}
        api.set_sprint(your_mod_name, player, state.detected, sprint_settings)
    end
end)

api.register_server_step(your_mod_name, "DRAIN", tonumber(core.settings:get(your_mod_name .. ".drain_step")) or 0.2, function(player, state, dtime)
	if state.detected and api.is_player_draining(player) then
		mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_SPRINT)
	end
end)
