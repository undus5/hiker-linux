-- put user settings here
-- this module will be loaded after everything else when the application starts
-- it will be automatically reloaded when saved

local core = require "core"
local keymap = require "core.keymap"
local config = require "core.config"
local style = require "core.style"

------------------------------ Fonts -----------------------------------------

-- https://lite-xl.com/user-guide/configuration/#fonts

local font_dir = USERDIR .. "/fonts/"

local latin_ttf = font_dir .. "JetBrainsMonoNL-Regular.ttf"
local sc_ttf = font_dir .. "SarasaTermSC-Regular.ttf"
local tc_ttf = font_dir .. "SarasaTermTC-Regular.ttf"
local jp_ttf = font_dir .. "SarasaTermJ-Regular.ttf"
local kr_ttf = font_dir .. "SarasaTermK-Regular.ttf"

local latin_italic_ttf = font_dir .. "JetBrainsMonoNL-Italic.ttf"
local sc_italic_ttf = font_dir .. "SarasaTermSC-Italic.ttf"
local tc_italic_ttf = font_dir .. "SarasaTermTC-Italic.ttf"
local jp_italic_ttf = font_dir .. "SarasaTermJ-Italic.ttf"
local kr_italic_ttf = font_dir .. "SarasaTermK-Italic.ttf"

local font_size = 16 * SCALE
local load = renderer.font.load
local loaded_fonts = {}
local font_file

-- code font

font_file = io.open(latin_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(latin_ttf, font_size))
end

font_file = io.open(sc_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(sc_ttf, font_size))
end

font_file = io.open(tc_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(tc_ttf, font_size))
end

font_file = io.open(jp_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(jp_ttf, font_size))
end

font_file = io.open(kr_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(kr_ttf, font_size))
end

font_file = io.open(latin_italic_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(latin_italic_ttf, font_size))
end

font_file = io.open(sc_italic_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(sc_italic_ttf, font_size))
end

font_file = io.open(tc_italic_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(tc_italic_ttf, font_size))
end

font_file = io.open(jp_italic_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(jp_italic_ttf, font_size))
end

font_file = io.open(kr_italic_ttf, "r")
if font_file then
  io.close(font_file)
  table.insert(loaded_fonts, load(kr_italic_ttf, font_size))
end

if #loaded_fonts > 0 then
  style.font = renderer.font.group(loaded_fonts)
  style.code_font = renderer.font.group(loaded_fonts)
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

