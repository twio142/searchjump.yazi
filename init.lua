local KEYS_LABEL = {
	"p", "b", "e", "t", "a", "o", "i", "n", "s", "r", "h", "l", "d", "c",
	"u", "m", "f", "g", "w", "v", "k", "j", "x", "y", "q","z"
}

local function get_match_position(name,find_str)
	if find_str == "" or find_str == nil then
		return nil,nil
	end

	local startPos, endPos = string.find(string.lower(name), find_str)
	if startPos then
		return startPos, endPos
	else
		return nil,nil
	end
end

local set_match_label = ya.sync(function(state,url,name)
	local span = {}
	local key = ""
	if state.match[url].key then
		key = state.match[url].key
	end

	local startPos = state.match[url].startPos
	local endPos = state.match[url].endPos

	if startPos == 1 then
		span = ui.Line{ui.Span(name:sub(1,endPos)):fg("#000000"):bg("#73AC3A"),ui.Span(key):fg("#EADFC8"):bg("#BA603D"),ui.Span(name:sub(endPos+1,#name)):fg("#928374") }
	else
		span = ui.Line{ui.Span(name:sub(1,startPos-1)):fg("#928374"),ui.Span(name:sub(startPos,endPos)):fg("#000000"):bg("#73AC3A"),ui.Span(key):fg("#EADFC8"):bg("#BA603D") ,ui.Span(name:sub(endPos+1,#name)):fg("#928374")}
	end
	return span
end)

local update_match_table = ya.sync(function (state,folder,find_str)
	if not folder then
		return
	end

	for _, file in ipairs(folder.window) do
		local name = file.name:gsub("\r", "?", 1)
		local url = tostring(file.url)
		local startPos, endPos = get_match_position(name,find_str)
		if startPos then
			state.match[url] = {
				key = nil,
				startPos = startPos,
				endPos = endPos,
			}
		
			state.next_char[#state.next_char +1] = string.lower(name:sub(endPos+1,endPos+1))
		end
	end
end)

local record_match_file = ya.sync(function (state,find_str)
	if state.match == nil then
		state.match = {}
	end

	if state.next_char == nil then
		state.next_char = {}
	end

	-- record match file from current window
	update_match_table(Folder:by_kind(Folder.CURRENT),find_str)

	-- record match file from parent window
	update_match_table(Folder:by_kind(Folder.PARENT),find_str)

	-- record match file from preview window
	update_match_table(Folder:by_kind(Folder.PREVIEW),find_str)

	-- get valid key list
	local valid_label = {}
	for _, value in ipairs(KEYS_LABEL) do
		local found = false
		for _, v in ipairs(state.next_char) do
			if value == v then
				found = true
				break
			end
		end
	
		if not found then
			table.insert(valid_label,value)
		end
	end

	-- assign valid key to each match file
	local i = 1
	for url, _ in pairs(state.match) do
		state.match[url].key =  valid_label[i]
		i = i + 1
	end

	-- flush page
	ya.manager_emit("peek", { force = true })
	ya.render()
end)

local toggle_ui = ya.sync(function(st)

	if st.highlights or st.mode then
		File.highlights, Status.mode, st.highlights, st.mode = st.highlights, st.mode, nil, nil
		ya.manager_emit("peek", { force = true })
		ya.render()
		return
	end

	st.highlights, st.mode = File.highlights, Status.mode

	if st.target_str == nil then
		st.target_str = ""
	end

	File.highlights = function(self, file)
		local span = {}
		local name = file.name:gsub("\r", "?", 1)
		local url = tostring(file.url)

		if st.match and st.match[url] then
			span = set_match_label(url,name)
		else
			span = ui.Span(name):fg("#928374")		
		end

		return span
	end

	Status.mode = function(self)
		local style = self.style()
		return ui.Line {
			ui.Span(THEME.status.separator_open):fg(style.bg),
			ui.Span(" SJ-" .. tostring(cx.active.mode):upper() .. " "):style(style),
		}
	end

	ya.manager_emit("peek", { force = true })
end)


local set_target_str =ya.sync(function(state,input_str)
	local is_match_key = false
	if state.match then
		for url, _ in pairs(state.match) do
			if state.match[url].key == input_str:sub(#input_str,#input_str) then
				ya.manager_emit(url:match("[/\\]$") and "cd" or "reveal", { url })
				is_match_key = true
			end
		end
	end
	-- ya.err(input_str:sub(#input_str,#input_str))
	state.match = nil
	state.next_char = nil
	state.target_str = input_str


	record_match_file(input_str)

	ya.render()
	if is_match_key then
		return true
	else
		return false
	end
end)

local clear_state_str =ya.sync(function(state)
	state.target_str = ""
	ya.render()

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
				local want_exit = set_target_str(value)				
				if want_exit then
					break
				end
			else
				break
			end
		end

		clear_state_str()
		toggle_ui()

	end
}
