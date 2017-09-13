local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local path_to_icons = "/home/sam/.icons/numix-icon-theme/Numix/24/status/"
local warning_displayed = false

battery_widget = wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = true
    },
    layout = wibox.container.margin(brightness_icon, 0, 0, 3),
    set_image = function(self, path)
        self.icon.image = path
    end
}

-- Popup with battery info
battery_popup = awful.tooltip({objects = {battery_widget}})

-- To use colors from beautiful theme put
-- following lines in rc.lua before require("battery")
--
-- beautiful.tooltip_fg = beautiful.fg_normal
-- beautiful.tooltip_bg = beautiful.bg_normal

watch(
    "acpi", 1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local batteryType
        local _, status, charge_str, time = string.match(stdout, '(.+): (%a+), (%d?%d%d)%%,? ?.*')
        local charge = tonumber(charge_str)

        if (charge < 10) then
            show_battery_warning()
        else
            warning_displayed = false
        end

        if (charge >= 0 and charge < 10) then batteryType="battery-000%s"
        elseif (charge >= 10 and charge < 20) then batteryType="battery-010%s"
        elseif (charge >= 20 and charge < 30) then batteryType="battery-020%s"
        elseif (charge >= 30 and charge < 40) then batteryType="battery-030%s"
        elseif (charge >= 40 and charge < 50) then batteryType="battery-040%s"
        elseif (charge >= 50 and charge < 60) then batteryType="battery-050%s"
        elseif (charge >= 60 and charge < 70) then batteryType="battery-060%s"
        elseif (charge >= 70 and charge < 80) then batteryType="battery-070%s"
        elseif (charge >= 80 and charge < 90) then batteryType="battery-080%s"
        elseif (charge >= 90 and charge < 100) then batteryType="battery-090%s"
        else batteryType="battery-100%s"
        end
        if status == 'Charging' then
            batteryType = string.format(batteryType,'-charging')
        else
            batteryType = string.format(batteryType,'')
        end
        widget.image = path_to_icons .. batteryType .. ".svg"

        -- Update popup text
        -- TODO: Filter long lines
        battery_popup.text = string.gsub(stdout, "\n$", "")
    end,
    battery_widget
)

-- Alternative to tooltip - popup message shown by naughty library. You can compare both and choose the preferred one
--function show_battery_status()
--    awful.spawn.easy_async([[bash -c 'acpi']],
--        function(stdout, stderr, reason, exit_code)
--            naughty.notify{
--                text = stdout,
--                title = "Battery status",
--                timeout = 5, hover_timeout = 0.5,
--                width = 200,
--            }
--        end
--    )
--end
--battery_widget:connect_signal("mouse::enter", function() show_battery_status() end)

function show_battery_warning()
    if (warning_displayed == false) then
        warning_displayed = true
        naughty.notify{
            icon = path_to_icons .. "battery-empty-symbolic.svg",
            icon_size=dpi(50),
            text = "Huston, we have a problem",
            title = "Battery is dying",
            timeout = 30, hover_timeout = 0.5,
            width = dpi(300),
        }
    end
end
