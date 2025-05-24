local your_mod_name = core.get_current_modname()

local settings = {
	enable_sprint = true,
    	aux1 = false,
    	double_tap = true,
    	tap_interval = 0.5,
}

dg_sprint_core.RegisterStep(your_mod_name, "DETECT", 0.1, function(player, state, dtime)
	
	local detected = dg_sprint_core.IsSprintKeyDetected(player, false, settings.double_tap, settings.tap_interval) and dg_sprint_core.IsMoving(player)

	if detected ~= state.detected then
		state.detected = detected
	end

end)

dg_sprint_core.RegisterStep(your_mod_name, "SPRINT", 0.2, function(player, state, dtime)
	local detected = state.detected
	if detected ~= state.is_sprinting then
		state.is_sprinting = detected
		dg_sprint_core.McSprint(player, state.is_sprinting)
	end
end)



