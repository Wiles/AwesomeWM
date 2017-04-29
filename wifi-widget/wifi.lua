local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local path_to_icons = "/usr/share/icons/Arc/status/symbolic/"
local interface = "wlan0"

wifi_widget = wibox.widget {
    {
        id = "icon",
        image = path_to_icons .. "network-wireless-offline-symbolic.svg",
        resize = false,
        widget = wibox.widget.imagebox,
    },
    layout = wibox.container.margin(brightness_icon, 0, 0, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}

-- Popup with wifi info
wifi_popup = awful.tooltip({objects = {wifi_widget}})

local function parse_strength(interface, str)

    a = string.sub(str, 1, string.find(str, "/70") - 1)
    strength = string.sub(a, string.find(a, "=[^=]*$") + 1)

    return math.floor(tonumber(strength) / 0.7)
end

watch(
    "iwconfig "..interface, 1,
    function(widget, stdout, stderr, reason, exit_code)

        wifi_popup.text = string.gsub(stderr, "\n$", "")
        strength = parse_strength(interface, stdout)

        local strength_icon_name
        if (strength >= 0 and strength < 25) then strength_icon_name="network-wireless-signal-weak-symbolic"
        elseif (strength >= 25 and strength < 50) then strength_icon_name="network-wireless-signal-ok-symbolic"
        elseif (strength >= 50 and strength < 75) then strength_icon_name="network-wireless-signal-good-symbolic"
        elseif (strength >= 75 and strength <= 100) then strength_icon_name="network-wireless-signal-excellent-symbolic"
        end
        widget.image = path_to_icons .. strength_icon_name .. ".svg"

        wifi_popup.text = string.gsub(stdout, "\n$", "")

    end,
    wifi_widget
)
