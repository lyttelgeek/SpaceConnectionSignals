-- settings.lua
data:extend({
  {
    type = "bool-setting",
    name = "space-connection-signals-only-direct-connections",
    setting_type = "startup",
    default_value = false,
    order = "a[gen]-a[direct-only]",
  },
  {
    type = "bool-setting",
    name = "space-connection-signals-one-per-pair",
    setting_type = "startup",
    default_value = false,
    order = "a[gen]-b[one-per-pair]",
  },
})