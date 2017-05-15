local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local path_to_icons = "/usr/share/icons/Arc/status/symbolic/"
local interface = "wlan0"

wifi_widget = wibox.widget {
    {
        id = "icon",
        image = path_to_icons .. "network-wireless-offline-symbolic.svg",
        resize = true,
        widget = wibox.widget.imagebox,
    },
    layout = wibox.container.margin(brightness_icon, 0, 0, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}

-- Popup with wifi info
wifi_popup = awful.tooltip({objects = {wifi_widget}})

local function parse_strength(str)

    local startIndex = string.find(str, "/70");
    if not startIndex then
        return 0
    else
        local a = string.sub(str, 1, startIndex - 1)
        local strength = string.sub(a, string.find(a, "=[^=]*$") + 1)

        return math.floor(tonumber(strength) / 0.7)
    end
end

watch(
    "iwconfig "..interface, 10,
    function(widget, stdout, stderr, reason, exit_code)

        if (string.len(stderr) > 0) then
            wifi_popup.text = string.gsub(stderr, "\n$", "")
            widget.image=path_to_icons .. "network-wireless-offline-symbolic.svg"
        else
            strength = parse_strength(stdout)

            local strength_icon_name
            if (strength == 0) then strength_icon_name="network-wireless-offline-symbolic"
            elseif (strength > 0 and strength < 25) then strength_icon_name="network-wireless-signal-weak-symbolic"
            elseif (strength >= 25 and strength < 50) then strength_icon_name="network-wireless-signal-ok-symbolic"
            elseif (strength >= 50 and strength < 75) then strength_icon_name="network-wireless-signal-good-symbolic"
            elseif (strength >= 75 and strength <= 100) then strength_icon_name="network-wireless-signal-excellent-symbolic"
            end
            widget.image = path_to_icons .. strength_icon_name .. ".svg"

            wifi_popup.text = string.gsub(stdout, "\n$", "")
        end
    end,
    wifi_widget
)
