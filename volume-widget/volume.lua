local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local path_to_icons = "/home/sam/.icons/numix-icon-theme/Numix/24/status/"

volume_widget = wibox.widget {
    {
        id = "icon",
        image = path_to_icons .. "audio-volume-muted-symbolic.svg",
        resize = true,
        widget = wibox.widget.imagebox,
    },
    layout = wibox.container.margin(brightness_icon, 0, 0, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}
-- Popup with volume info
volume_popup = awful.tooltip({objects = {volume_widget}})

--[[ allows control volume level by:
- clicking on the widget to mute/unmute
- scrolling when curson is over the widget
]]
volume_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4) then
        awful.spawn("amixer -D pulse sset Master 5%+", false)
    elseif (button == 5) then
        awful.spawn("amixer -D pulse sset Master 5%-", false)
    elseif (button == 1) then
        awful.spawn("amixer -D pulse sset Master toggle", false)
    end
end)

watch(
    'amixer -D pulse sget Master', 1,
    function(widget, stdout, stderr, reason, exit_code)
        local mute = string.match(stdout, "%[(o%D%D?)%]")
        local volume = string.match(stdout, "(%d?%d?%d)%%")
        volume = tonumber(string.format("% 3d", volume))
        local volume_icon_names
        if mute == "off" then volume_icon_name="audio-volume-muted"
        elseif (volume == 0) then volume_icon_name="audio-volume-zero-panel"
        elseif (volume > 0 and volume < 33) then volume_icon_name="audio-volume-low"
        elseif (volume >= 33 and volume < 66) then volume_icon_name="audio-volume-medium"
        else volume_icon_name="audio-volume-high"
        end
        widget.image = path_to_icons .. volume_icon_name .. ".svg"

        volume_popup.text = string.gsub(stdout, "\n$", "")
    end,
    volume_widget
)
