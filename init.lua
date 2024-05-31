
local toggle_ui = ya.sync(function(st)

	if st.highlights or st.mode then
		File.highlights, Status.mode, st.highlights, st.mode = st.highlights, st.mode, nil, nil
		ya.render()
		return
	end

	st.highlights, st.mode = File.highlights, Status.mode

	if st.target_str == nil then
		st.target_str = ""
	end

	File.highlights = function(self, file)
		local name = file.name:gsub("\r", "?", 1)
		ya.err(st.target_str)

		return {
			ui.Line{ui.Span(name):fg("#928374"):bg("#201B14"),ui.Span(st.target_str):fg("#928374"):bg("#201B14") }
		}		
	end

	Status.mode = function(self)
		local style = self.style()
		return ui.Line {
			ui.Span(THEME.status.separator_open):fg(style.bg),
			ui.Span(" SJ-" .. tostring(cx.active.mode):upper() .. " "):style(style),
		}
	end

	ya.manager_emit("peek", { force = true })
	ya.render()
end)


local set_target_str =ya.sync(function(state,input_str)
	state.target_str = input_str
end)

return {
	-- setup = function(state, opts)
	-- 	-- Save the user configuration to the plugin's state
	-- 	if (opts ~= nil and opts.icon_fg ~= nil ) then
	-- 		state.opt_icon_fg  = opts.icon_fg
	-- 	end
	-- end,

	entry = function(_, args)

		-- set_opts_default()

		-- local action = args[1]
		toggle_ui()



		local input = ya.input({
			realtime = true,
			title = "",
			position = { "bottom-right", y = -1, w = 10 },
		})


		while true do
			local value, event = input:recv()
			if event == 3 then
				set_target_str(value)
				ya.err(value)
				ya.render()
			else
				break
			end
		end

		toggle_ui()

	end
}
