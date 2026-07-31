-- put user settings here
-- this module will be loaded after everything else when the application starts
-- it will be automatically reloaded when saved

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

------------------------------ Fonts -----------------------------------------

-- https://lite-xl.com/user-guide/configuration/#fonts

local font_size = 16 * SCALE
local fonts_loaded = {}

local font_dir = USERDIR .. "/fonts/"

local ttf_latin = font_dir .. "JetBrainsMonoNL-Regular.ttf"
local ttf_sc = font_dir .. "SarasaTermSC-Regular.ttf"
local ttf_tc = font_dir .. "SarasaTermTC-Regular.ttf"
local ttf_jp = font_dir .. "SarasaTermJ-Regular.ttf"
local ttf_kr = font_dir .. "SarasaTermK-Regular.ttf"

local ttf_italic_latin = font_dir .. "JetBrainsMonoNL-Italic.ttf"
local ttf_italic_sc = font_dir .. "SarasaTermSC-Italic.ttf"
local ttf_italic_tc = font_dir .. "SarasaTermTC-Italic.ttf"
local ttf_italic_jp = font_dir .. "SarasaTermJ-Italic.ttf"
local ttf_italic_kr = font_dir .. "SarasaTermK-Italic.ttf"

local function file_exists(path)
   local f = io.open(path, "r")
   if f then
      f:close()
      return true
   end
   return false
end

if file_exists(ttf_latin) then
  table.insert(fonts_loaded, renderer.font.load(ttf_latin, font_size))
end

if file_exists(ttf_sc) then
  table.insert(fonts_loaded, renderer.font.load(ttf_sc, font_size))
end

if file_exists(ttf_tc) then
  table.insert(fonts_loaded, renderer.font.load(ttf_tc, font_size))
end

if file_exists(ttf_jp) then
  table.insert(fonts_loaded, renderer.font.load(ttf_jp, font_size))
end

if file_exists(ttf_kr) then
  table.insert(fonts_loaded, renderer.font.load(ttf_kr, font_size))
end

if file_exists(ttf_italic_latin) then
  table.insert(fonts_loaded, renderer.font.load(ttf_italic_latin, font_size))
end

if file_exists(ttf_italic_sc) then
  table.insert(fonts_loaded, renderer.font.load(ttf_italic_sc, font_size))
end

if file_exists(ttf_italic_tc) then
  table.insert(fonts_loaded, renderer.font.load(ttf_italic_tc, font_size))
end

if file_exists(ttf_italic_jp) then
  table.insert(fonts_loaded, renderer.font.load(ttf_italic_jp, font_size))
end

if file_exists(ttf_italic_kr) then
  table.insert(fonts_loaded, renderer.font.load(ttf_italic_kr, font_size))
end

if #fonts_loaded > 0 then
  style.font = renderer.font.group(fonts_loaded)
  style.code_font = renderer.font.group(fonts_loaded)
end

------------------------------ Themes ----------------------------------------

-- light theme:
-- core.reload_module("colors.summer")

--------------------------- Key bindings -------------------------------------

-- key binding:
-- keymap.add { ["ctrl+escape"] = "core:quit" }

-- pass 'true' for second parameter to overwrite an existing binding
-- keymap.add({ ["ctrl+pageup"] = "root:switch-to-previous-tab" }, true)
-- keymap.add({ ["ctrl+pagedown"] = "root:switch-to-next-tab" }, true)

------------------------------- Fonts ----------------------------------------

-- customize fonts:
-- style.font = renderer.font.load(DATADIR .. "/fonts/FiraSans-Regular.ttf", 14 * SCALE)
-- style.code_font = renderer.font.load(DATADIR .. "/fonts/JetBrainsMono-Regular.ttf", 14 * SCALE)
--
-- DATADIR is the location of the installed Lite XL Lua code, default color
-- schemes and fonts.
-- USERDIR is the location of the Lite XL configuration directory.
--
-- font names used by lite:
-- style.font          : user interface
-- style.big_font      : big text in welcome screen
-- style.icon_font     : icons
-- style.icon_big_font : toolbar icons
-- style.code_font     : code
--
-- the function to load the font accept a 3rd optional argument like:
--
-- {antialiasing="grayscale", hinting="full", bold=true, italic=true, underline=true, smoothing=true, strikethrough=true}
--
-- possible values are:
-- antialiasing: grayscale, subpixel
-- hinting: none, slight, full
-- bold: true, false
-- italic: true, false
-- underline: true, false
-- smoothing: true, false
-- strikethrough: true, false

------------------------------ Plugins ----------------------------------------

-- disable plugin loading setting config entries:

-- disable plugin detectindent, otherwise it is enabled by default:
-- config.plugins.detectindent = false

---------------------------- Miscellaneous -------------------------------------

-- modify list of files to ignore when indexing the project:
-- config.ignore_files = {
--   -- folders
--   "^%.svn/",        "^%.git/",   "^%.hg/",        "^CVS/", "^%.Trash/", "^%.Trash%-.*/",
--   "^node_modules/", "^%.cache/", "^__pycache__/",
--   -- files
--   "%.pyc$",         "%.pyo$",       "%.exe$",        "%.dll$",   "%.obj$", "%.o$",
--   "%.a$",           "%.lib$",       "%.so$",         "%.dylib$", "%.ncb$", "%.sdf$",
--   "%.suo$",         "%.pdb$",       "%.idb$",        "%.class$", "%.psd$", "%.db$",
--   "^desktop%.ini$", "^%.DS_Store$", "^%.directory$",
-- }

