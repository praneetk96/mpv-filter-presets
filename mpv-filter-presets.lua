--  ____ _  __
--  |  _ \ |/ /  Praneet Kumar
--  | |_)| ' /   https://www.youtube.com/@iampraneetkumar
--  |  __/ . \   https://www.gitlab.com/praneetk96
--  |_|  |_|\_\
--
--  My Lua script to add a filter preset menu for mpv.

local mp             = require 'mp'

-- ordered preset list
local preset_names   = {
    "None",
    "Cinematic",
    "Cool Tone",
    "Custom",
    "Deep Black",
    "Dramatic",
    "Ghibli Style",
    "Neon Pop",
    "Night Mode",
    "Nostalgic",
    "Sharpen",
    "Soft Pastel",
    "Vivid",
    "Warm Tone",
}

-- deband presets
local DEBAND_LIGHT   = { 2, 30, 16, 4 }
local DEBAND_MED     = { 3, 30, 16, 5 }
local DEBAND_STRONG  = { 4, 35, 18, 6 }

-- sharpness presets
local SHARP_LIGHT    = { 5, 5, 0.2 }
local SHARP_MED      = { 5, 5, 0.35 }
local SHARP_STRONG   = { 7, 7, 0.5 }

-- preset definitions
local presets        = {

    ["None"] = {
        brightness = 0,
        contrast = 0,
        saturation = 0,
        gamma = 0,
        hue = 0,
        sharp = nil,
        deband = nil
    },

    ["Custom"] = {
        brightness = 0,
        contrast = -20,
        saturation = 40,
        gamma = -10,
        hue = 0,
        sharp = nil,
        deband = nil
    },

    ["Vivid"] = {
        brightness = 5,
        contrast = 15,
        saturation = 25,
        gamma = 0,
        hue = 0,
        sharp = SHARP_LIGHT,
        deband = DEBAND_LIGHT
    },

    ["Warm Tone"] = {
        brightness = 5,
        contrast = 5,
        saturation = 10,
        gamma = 5,
        hue = 15,
        sharp = SHARP_LIGHT,
        deband = DEBAND_MED
    },

    ["Cool Tone"] = {
        brightness = 0,
        contrast = 10,
        saturation = 5,
        gamma = 0,
        hue = -15,
        sharp = SHARP_LIGHT,
        deband = DEBAND_MED
    },

    ["Soft Pastel"] = {
        brightness = 10,
        contrast = -10,
        saturation = -15,
        gamma = 5,
        hue = 0,
        sharp = SHARP_MED,
        deband = DEBAND_STRONG
    },

    ["Cinematic"] = {
        brightness = -5,
        contrast = 20,
        saturation = -10,
        gamma = -5,
        hue = 5,
        sharp = SHARP_LIGHT,
        deband = DEBAND_STRONG
    },

    ["Dramatic"] = {
        brightness = -10,
        contrast = 30,
        saturation = 15,
        gamma = -10,
        hue = 0,
        sharp = nil,
        deband = DEBAND_STRONG
    },

    ["Night Mode"] = {
        brightness = -20,
        contrast = 5,
        saturation = -5,
        gamma = -10,
        hue = 0,
        sharp = nil,
        deband = DEBAND_STRONG
    },

    ["Nostalgic"] = {
        brightness = 5,
        contrast = 10,
        saturation = -20,
        gamma = 0,
        hue = 20,
        sharp = SHARP_LIGHT,
        deband = DEBAND_MED
    },

    ["Ghibli Style"] = {
        brightness = 8,
        contrast = -5,
        saturation = 15,
        gamma = 5,
        hue = 5,
        sharp = SHARP_MED,
        deband = DEBAND_MED
    },

    ["Neon Pop"] = {
        brightness = 5,
        contrast = 20,
        saturation = 40,
        gamma = 0,
        hue = 0,
        sharp = SHARP_LIGHT,
        deband = DEBAND_LIGHT
    },

    ["Deep Black"] = {
        brightness = -15,
        contrast = 5,
        saturation = 25,
        gamma = -15,
        hue = 0,
        sharp = nil,
        deband = DEBAND_STRONG
    },

    ["Sharpen"] = {
        brightness = 0,
        contrast = 5,
        saturation = 0,
        gamma = 0,
        hue = 0,
        sharp = SHARP_MED,
        deband = DEBAND_MED
    },

}

local active         = false
local index          = 1
local current_preset = "None"
local saved_state    = {}

------------------------------------------------
-- Save current video state
------------------------------------------------

local function save_state()
    saved_state.brightness = mp.get_property_number("brightness", 0)
    saved_state.contrast = mp.get_property_number("contrast", 0)
    saved_state.saturation = mp.get_property_number("saturation", 0)
    saved_state.gamma = mp.get_property_number("gamma", 0)
    saved_state.hue = mp.get_property_number("hue", 0)

    saved_state.vf = mp.get_property_native("vf")
end

------------------------------------------------
-- Restore previous state
------------------------------------------------

local function restore_state()
    mp.set_property_number("brightness", saved_state.brightness)
    mp.set_property_number("contrast", saved_state.contrast)
    mp.set_property_number("saturation", saved_state.saturation)
    mp.set_property_number("gamma", saved_state.gamma)
    mp.set_property_number("hue", saved_state.hue)

    mp.set_property_native("vf", saved_state.vf)
end

------------------------------------------------
-- Apply preset
------------------------------------------------

local function apply_preset(name)
    local p = presets[name]
    if not p then return end

    mp.set_property_number("brightness", p.brightness)
    mp.set_property_number("contrast", p.contrast)
    mp.set_property_number("saturation", p.saturation)
    mp.set_property_number("gamma", p.gamma)
    mp.set_property_number("hue", p.hue)

    mp.command("vf remove @sharp")
    mp.command("vf remove @deband")

    if p.sharp then
        mp.command(string.format(
            "vf add @sharp:unsharp=%d:%d:%f",
            p.sharp[1], p.sharp[2], p.sharp[3]))
    end

    if p.deband then
        mp.command(string.format(
            "vf add @deband:deband=iterations=%d:threshold=%d:range=%d:grain=%d",
            p.deband[1], p.deband[2], p.deband[3], p.deband[4]))
    end

    current_preset = name
    mp.osd_message("Preset: " .. name, 1.5)
end

------------------------------------------------
-- OSD menu
------------------------------------------------

local function render_menu()
    local text = "Filter Presets\n\n"

    for i, name in ipairs(preset_names) do
        if i == index then
            text = text .. "▶ " .. name .. "\n"
        else
            text = text .. "  " .. name .. "\n"
        end
    end

    text = text .. "\n↑ ↓ preview   Enter apply   ESC cancel"

    mp.osd_message(text, 999)
end

------------------------------------------------
-- Navigation
------------------------------------------------

local function move_up()
    index = index - 1
    if index < 1 then index = #preset_names end

    apply_preset(preset_names[index])
    render_menu()
end

local function move_down()
    index = index + 1
    if index > #preset_names then index = 1 end

    apply_preset(preset_names[index])
    render_menu()
end

------------------------------------------------
-- Menu control
------------------------------------------------

local function close_menu(apply)
    if not apply then
        restore_state()
    end

    active = false

    mp.remove_key_binding("menu_up")
    mp.remove_key_binding("menu_down")
    mp.remove_key_binding("menu_enter")
    mp.remove_key_binding("menu_esc")

    mp.osd_message("")
end

local function open_menu()
    if active then return end

    active = true

    -- find index of current preset
    for i, name in ipairs(preset_names) do
        if name == current_preset then
            index = i
            break
        end
    end

    save_state()

    apply_preset(preset_names[index])
    render_menu()

    mp.add_forced_key_binding("UP", "menu_up", move_up)
    mp.add_forced_key_binding("DOWN", "menu_down", move_down)

    mp.add_forced_key_binding("ENTER", "menu_enter",
        function() close_menu(true) end)

    mp.add_forced_key_binding("ESC", "menu_esc",
        function() close_menu(false) end)
end

------------------------------------------------
-- Keybind to open menu
------------------------------------------------

mp.add_key_binding("F6", "open_filter_menu", open_menu)
