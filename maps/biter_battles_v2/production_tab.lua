local Tabs = require 'comfy_panel.main'

local constants = {
  MAX_WIDTH = 790.0,
  HEADER_COLOR = { r=0.98, g=0.66, b=0.22 },
  TRACKED_ITEMS = {
    "iron-plate",
    "copper-plate",
    "steel-plate",
    "coal",
    "crude-oil",
    "automation-science-pack",
    "logistic-science-pack",
    "military-science-pack",
    "chemical-science-pack",
    "production-science-pack",
    "utility-science-pack",
    "space-science-pack"
  }
}

local function apply_header_style(element)
  element.style.font = "default-bold"
  element.style.font_color = constants["HEADER_COLOR"]
  element.style.horizontal_align = "center"
end

local function show_force_statistics(element, force, input)
  local precisions = { defines.flow_precision_index.one_minute, defines.flow_precision_index.ten_minutes, defines.flow_precision_index.one_hour }
  local item_production_statistics = force.item_production_statistics
  local fluid_production_statistics = force.fluid_production_statistics
  local force_table = element.add { type = "table", name = "production_stats_" .. tostring(input) .. "_table", column_count = 4, draw_horizontal_lines = true }
  force_table.style.left_cell_padding = 5
  force_table.style.right_cell_padding = 5

  local table_width = constants["MAX_WIDTH"] / 2.0
  local default_column_width = table_width / 6.0
  local column_widths = { default_column_width * 2, default_column_width, default_column_width, default_column_width }

  local headers = { "Timeframe", "1m", "10m", "1h" }
  for index, header in ipairs(headers) do
    local header_cell = force_table.add { type = "label", name = "production_count_" .. tostring(input) .. "_table_header_" .. index, caption = header }
    apply_header_style(header_cell)
    header_cell.style.width = column_widths[index]
    header_cell.style.horizontal_align = "center"
  end

  for _, item in ipairs(constants["TRACKED_ITEMS"]) do
    local wadus = {}
    local row = {}
    local sprite_prefix = (item == "crude-oil") and "fluid/" or "item/"
    local icon = { type = "sprite", name = "production_sprite_" .. item, sprite = sprite_prefix .. item }

    table.insert(row, icon)

    for _, precision in ipairs(precisions) do
      local item_count = 0
      if item == "crude-oil" then
        item_count = fluid_production_statistics.get_flow_count { name = item, input = input, precision_index = precision }
      else
        item_count = item_production_statistics.get_flow_count { name = item, input = input, precision_index = precision }
      end
      local caption = (item_count < 1000) and string.format("%.0f", item_count) or string.format("%.2fk", item_count / 1000.0)
      local label = { type = "label", name = "production_count_" .. precision .. "_" .. item, caption = caption }

      table.insert(row, label)
    end

    for index, cell in ipairs(row) do
      cell = force_table.add(cell)
      cell.style.width = column_widths[index]
      cell.style.horizontal_align = "center"
    end
  end
end

local function show_force_production_stats(element, force)
  local force_label = element.add { type = "label", name = "production_stats_" .. force.name, caption = force.name }
  apply_header_style(force_label)
  force_label.style.horizontally_stretchable = true
  force_label.style.minimal_width = constants["MAX_WIDTH"]
	local t = element.add { type = "table", name = "production_stats_" .. force.name .. "_table", column_count = 2 }
	local column_widths = { constants["MAX_WIDTH"] / 2, constants["MAX_WIDTH"] / 2 }
	local headers = {
		[1] = "Production",
		[2] = "Consumption",
	}
	for i, w in ipairs(column_widths) do
    local label = t.add { type = "label", caption = headers[i] }
    apply_header_style(label)
    label.style.width = w
  	label.style.horizontal_align = "center"
	end

  show_force_statistics(t, force, true)
  show_force_statistics(t, force, false)
end

local function show_production_stats(element)
  local forces = { "north", "south" }
	local scroll_pane = element.add { type = "scroll-pane", name = "production_stats_flow", horizontal_scroll_policy = "never" }

  local title_label = scroll_pane.add { type = "label", name = "production_stats_header", caption = "Production stats" }
  apply_header_style(title_label)
  title_label.style.horizontal_align = "center"
  title_label.style.horizontally_stretchable = true
  title_label.style.minimal_width = constants["MAX_WIDTH"]

  for _, force in ipairs(forces) do
    show_force_production_stats(scroll_pane, game.forces[force])
  end
end

local build_config_gui = (function (player, frame)
	frame.clear()
  local status, err = pcall(function()
	show_production_stats(frame)
end)
game.print(serpent.block(err))
end)

comfy_panel_tabs["Production"] = build_config_gui
