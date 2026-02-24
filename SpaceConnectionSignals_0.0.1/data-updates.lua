-- Only run if there are planets or space-locations defined
if not data.raw["planet"] and not data.raw["space-location"] then return end

-- Capitalise display names for vanilla planets and space locations
local planet_display_names = {
  nauvis = "Nauvis",
  vulcanus = "Vulcanus",
  gleba = "Gleba",
  fulgora = "Fulgora",
  aquilo = "Aquilo",
  ["shattered-planet"] = "Shattered planet",
  ["solar-system-edge"] = "Solar system edge",
  
}

-- Build a combined list of planets and space-locations for galaxy order
local locations = {}
local location_indices = {}  -- galaxy index per location

-- Add planets
if data.raw["planet"] then
  for name, planet in pairs(data.raw["planet"]) do
    table.insert(locations, planet)
  end
end

-- Add space-locations, excluding any "unknown" placeholder
if data.raw["space-location"] then
  for name, loc in pairs(data.raw["space-location"]) do
    if not name:find("unknown") then
      table.insert(locations, loc)
    end
  end
end

-- Sort locations by .order if it exists, else by name
table.sort(locations, function(a, b)
  return (a.order or a.name) < (b.order or b.name)
end)

-- Assign galaxy index for sorting destinations later
for idx, loc in ipairs(locations) do
  location_indices[loc.name] = idx
end

-- Generate directional signals
for origin_idx, from in ipairs(locations) do
  -- Sort destinations by galaxy index
  table.sort(locations, function(a, b)
    return location_indices[a.name] < location_indices[b.name]
  end)

  for _, to in ipairs(locations) do
    if from.name ~= to.name then
      -- Internal signal name (lowercase or capitalised optional, doesn't affect display)
      local signal_name = "space-connection-signal-" .. from.name .. "-to-" .. to.name

      -- Determine display names: use hardcoded if available, otherwise fallback to name
      local from_display = planet_display_names[from.name] or from.name
      local to_display = planet_display_names[to.name] or to.name

      data:extend({
        {
          type = "virtual-signal",
          name = signal_name,
          subgroup = "space-connection-signals",

          -- Order: origin galaxy index first, then destination galaxy index
          order = string.format("a[%02d]-b[%02d]", origin_idx, location_indices[to.name]),
          icon_size = 64,
          icons = {
            { icon = "__space-age__/graphics/icons/planet-route.png" },

            -- Origin behind (slightly smaller, shifted for padding)
            {
              icon = from.icon,
              icon_size = from.icon_size or 64,
              scale = 0.36 * (64 / (from.icon_size or 64)),
              shift = {-7, -7}
            },

            -- Shadow for destination
            {
              icon = to.icon,
              icon_size = to.icon_size or 64,
              scale = 0.36 * (64 / (to.icon_size or 64)),
              shift = {8, 8},
              tint = {0, 0, 0, 0.3}
            },

            -- Destination in front (slightly larger)
            {
              icon = to.icon,
              icon_size = to.icon_size or 64,
              scale = 0.38 * (64 / (to.icon_size or 64)),
              shift = {6, 6}
            }
          },

          -- Use hardcoded display names if available, fallback to raw name
          localised_name = from_display .. " → " .. to_display
        }
      })
    end
  end
end