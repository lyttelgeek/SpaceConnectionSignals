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
    nauvis                = "Nauvis",
    vulcanus              = "Vulcanus",
    gleba                 = "Gleba",
    fulgora               = "Fulgora",
    aquilo                = "Aquilo",
    ["shattered-planet"]  = "Shattered planet",
    ["solar-system-edge"] = "Solar system edge",
}

-- Build combined ordered list of planets and space-locations
local locations = {}
local location_indices = {}

if data.raw["planet"] then
    for _, planet in pairs(data.raw["planet"]) do
        table.insert(locations, planet)
    end
end

if data.raw["space-location"] then
    for name, loc in pairs(data.raw["space-location"]) do
        if not name:find("unknown", 1, true) then
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
            direct[c.to]   = direct[c.to]   or {}
            direct[c.from][c.to] = true
            direct[c.to][c.from] = true
        end
    end
end

local function has_direct_connection(from_name, to_name)
    return (not direct) or (direct[from_name] and direct[from_name][to_name])
end

-- Scale factor applied to all icon layers
local ICON_SCALE = 0.82

-- Helper: build icon layers from either `icon` or `icons`
local function build_layers(source, scale, shift, tint)
    local layers = {}

    if source.icons then
        for _, layer in ipairs(source.icons) do
            local new_layer = table.deepcopy(layer)

            new_layer.scale = (new_layer.scale or 1) * scale
            new_layer.shift = shift

            if tint then
                new_layer.tint = tint
            end

            table.insert(layers, new_layer)
        end

    elseif source.icon then
        table.insert(layers, {
            icon = source.icon,
            icon_size = source.icon_size,
            scale = scale,
            shift = shift,
            tint = tint
        })
    end

    return layers
end

-- Bulk collect signals
local new_signals = {}

for _, from in ipairs(locations) do
    if from.icon or from.icons then
        local from_icon_size = type(from.icon_size) == "number" and from.icon_size or 64

        for _, to in ipairs(locations) do
            if from.name ~= to.name and (to.icon or to.icons) then
                local to_icon_size = type(to.icon_size) == "number" and to.icon_size or 64

                if has_direct_connection(from.name, to.name) then
                    if (not one_per_pair)
                    or (location_indices[from.name] < location_indices[to.name]) then

                        local signal_name =
                            "space-connection-signal-" .. from.name .. "-to-" .. to.name

                        local from_display = planet_display_names[from.name] or from.name
                        local to_display   = planet_display_names[to.name]   or to.name

                        -- Build icon list
                        local icons = {
                            -- Invisible anchor (centering)
                            {
                                icon = "__core__/graphics/empty.png",
                                icon_size = 30,
                                scale = 1,
                                shift = {0, 0},
                            },
                        }

                        -- Origin (top-left)
                        local from_layers = build_layers(
                            from,
                            ICON_SCALE * 0.36 * (64 / from_icon_size),
                            {-7 * ICON_SCALE, -7 * ICON_SCALE}
                        )

                        -- Destination shadow
                        local to_shadow_layers = build_layers(
                            to,
                            ICON_SCALE * 0.36 * (64 / to_icon_size),
                            {8 * ICON_SCALE, 8 * ICON_SCALE},
                            {0, 0, 0, 0.3}
                        )

                        -- Destination main
                        local to_layers = build_layers(
                            to,
                            ICON_SCALE * 0.38 * (64 / to_icon_size),
                            {6 * ICON_SCALE, 6 * ICON_SCALE}
                        )

                        -- Append all layers
                        for _, l in ipairs(from_layers) do table.insert(icons, l) end
                        for _, l in ipairs(to_shadow_layers) do table.insert(icons, l) end
                        for _, l in ipairs(to_layers) do table.insert(icons, l) end

                        table.insert(new_signals, {
                            type      = "virtual-signal",
                            name      = signal_name,
                            subgroup  = "space-connection-signals",
                            order     = string.format(
                                "a[%02d]-b[%02d]",
                                location_indices[from.name],
                                location_indices[to.name]
                            ),
                            icon_size = 64,
                            icons     = icons,
                            localised_name = {"", from_display, " → ", to_display},
                        })
                    end
                end
            end
        end
    end
end

if #new_signals > 0 then
    data:extend(new_signals)
end