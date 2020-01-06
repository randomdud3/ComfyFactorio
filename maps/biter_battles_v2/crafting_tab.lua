local Tabs = require 'comfy_panel.main'

local constants = {
  MAX_WIDTH = 790.0,
  HEADER_COLOR = { r=0.98, g=0.66, b=0.22 },
  MAX_CRAFTING_ITEMS_SHOWN = 10
}

local function apply_header_style(element)
  element.style.font = "default-bold"
  element.style.font_color = constants["HEADER_COLOR"]
  element.style.horizontal_align = "center"
end

local function show_player_crafting_queue(element, player)
  local flow = element.add { type = "flow", name = player.name .. "_crafting_queue", direction = "horizontal"}
  local name = flow.add { type = "label", name = player.name .. "_name", caption = player.name }
  apply_header_style(name)
  name.style.vertical_align = "center"
  for i, crafting_queue_item in ipairs(player.crafting_queue) do
    local product = player.force.recipes[crafting_queue_item.recipe].products[1]

    local sprite = "item/" .. product.name
    if product.type == 1 then
      sprite = "fluid/" .. product.name
    end

    local crafting_sprite = flow.add { type = "sprite-button", name = player.name .. "_crafting_item_" .. i .. "sprite", sprite = sprite, number = crafting_queue_item.count }
    if i == constants["MAX_CRAFTING_ITEMS_SHOWN"] then
      break
    end
  end
end

local function show_force_crafting_queue(element, force)
  local force_label = element.add { type = "label", name = "crafting_queue_" .. force.name, caption = force.name }
  apply_header_style(force_label)
  force_label.style.horizontal_align = "center"
  force_label.style.width = constants["MAX_WIDTH"]
  game.print(serpent.block(#element.children))

  local table = element.add { type = "table", name = "crafting_queue" .. force.name .. "_table", column_count = 1}
  for _, player in ipairs(force.connected_players) do
    show_player_crafting_queue(table, player)
  end
end

local function show_crafting_queues(element)
  local forces = { "north", "south" }
	local scroll_pane = element.add { type = "scroll-pane", name = "crafting_stats_scroll_pane", horizontal_scroll_policy = "never", direction = "vertical" }
  local flow = scroll_pane.add { type = "flow", name = "crafting_stats_flow", direction = "vertical"}

  local title_label = flow.add { type = "label", name = "crafting_stats_header", caption = "Crafting queues" }
  apply_header_style(title_label)
  title_label.style.horizontal_align = "center"
  title_label.style.horizontally_stretchable = true
  title_label.style.width = constants["MAX_WIDTH"]

  for _, force in ipairs(forces) do
    show_force_crafting_queue(flow, game.forces[force])
  end
end

local build_config_gui = (function (player, frame)
	frame.clear()
	show_crafting_queues(frame)
end)

comfy_panel_tabs["Crafting queues"] = build_config_gui
