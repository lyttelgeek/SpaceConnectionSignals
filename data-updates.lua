-- Only run if there are planets or space-locations defined
if not data.raw["planet"] and not data.raw["space-location"] then return end

-- Read startup settings (safe access pattern)
local only_direct =
  settings.startup["space-connection-signals-only-direct-connections"]
  and settings.startup["space-connection-signals-only-direct-connections"].value

local one_per_pair =
  settings.startup["space-connection-signals-one-per-pair"]
  and settings.startup["space-connection-signals-one-per-pair"].value

-- Capitalised display names for vanilla planets and space locations
local planet_display_names = {
  nauvis = "Nauvis",
  vulcanus = "Vulcanus",
  gleba = "Gleba",
  fulgora = "Fulgora",
  aquilo = "Aquilo",
  ["shattered-planet"] = "Shattered planet",
  ["solar-system-edge"] = "Solar system edge",
}

-- Build combined ordered list of planets and space-locations
local locations = {}
local location_indices = {}

-- Add planets
if data.raw["planet"] then
  for _, planet in pairs(data.raw["planet"]) do
    table.insert(locations, planet)
  end
end

-- Add space-locations (excluding placeholders)
if data.raw["space-location"] then
  for name, loc in pairs(data.raw["space-location"]) do
    if not name:find("unknown") then
      table.insert(locations, loc)
    end
  end
end

-- Sort once by galaxy order (fallback to name)
table.sort(locations, function(a, b)
  return (a.order or a.name) < (b.order or b.name)
end)

-- Assign galaxy index
for idx, loc in ipairs(locations) do
  location_indices[loc.name] = idx
end

-- Build adjacency map of direct starmap connections if required
local direct = nil
if only_direct then
  direct = {}
  local conns = data.raw["space-connection"] or {}

  for _, c in pairs(conns) do
    if c.from and c.to then
      direct[c.from] = direct[c.from] or {}
      direct[c.to] = direct[c.to] or {}

      -- Treat as undirected for filtering purposes
      direct[c.from][c.to] = true
      direct[c.to][c.from] = true
    end
  end
end

local function has_direct_connection(from_name, to_name)
  return (not direct) or (direct[from_name] and direct[from_name][to_name])
end

-- Bulk collect signals, then data:extend once
local new_signals = {}

for origin_idx, from in ipairs(locations) do
  for _, to in ipairs(locations) do
    if from.name ~= to.name then
      -- Direct-only filter
      if has_direct_connection(from.name, to.name) then
        -- One-per-pair filter (earlier galaxy index → later)
        if (not one_per_pair) or (location_indices[from.name] < location_indices[to.name]) then
          local signal_name =
            "space-connection-signal-" .. from.name .. "-to-" .. to.name

          local from_display =
            planet_display_names[from.name] or from.name

          local to_display =
            planet_display_names[to.name] or to.name

          table.insert(new_signals, {
            type = "virtual-signal",
            name = signal_name,
            subgroup = "space-connection-signals",
            order = string.format(
              "a[%02d]-b[%02d]",
              origin_idx,
              location_indices[to.name]
            ),
            icon_size = 64,
            icons = {
              { icon = "__space-age__/graphics/icons/planet-route.png" },

              {
                icon = from.icon,
                icon_size = from.icon_size or 64,
                scale = 0.36 * (64 / (from.icon_size or 64)),
                shift = {-7, -7}
              },

              {
                icon = to.icon,
                icon_size = to.icon_size or 64,
                scale = 0.36 * (64 / (to.icon_size or 64)),
                shift = {8, 8},
                tint = {0, 0, 0, 0.3}
              },

              {
                icon = to.icon,
                icon_size = to.icon_size or 64,
                scale = 0.38 * (64 / (to.icon_size or 64)),
                shift = {6, 6}
              }
            },

            
            localised_name = { "", from_display, " → ", to_display }
          })
        end
      end
    end
  end
end

if #new_signals > 0 then
  data:extend(new_signals)
end