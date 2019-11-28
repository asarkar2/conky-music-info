conky.config = {
-- Conky sample configuration

-- the list of variables has been removed from this file in favour
-- of keeping the documentation more maintainable.
-- Check http://conky.sf.net for an up-to-date-list.

-- set to yes if you want Conky to be forked in the background
	background = false,
-- X font when Xft is disabled, you can pick one with program xfontsel
--font 5x7
--font 6x10
--font 7x13
--font 8x13
--font 9x15
--font *mintsmild.se*
--font -*-*-*-*-*-*-34-*-*-*-*-*-*-*
-- font arial
-- Use Xft?
	use_xft = true,
-- Xft font when Xft is enabled
-- xftfont Bitstream Vera Sans Mono:size=9
	font = 'DejaVu Sans Mono :size=9',
-- xftfont DejaVu Sans Mono :size=7
-- Text alpha when using Xft
	xftalpha = 0.8,
-- Print everything to stdout?
-- out_to_console no
-- MPD host/port
-- mpd_host localhost
-- mpd_port 6600
-- mpd_password tinker_bell
-- Print everything to console?
-- out_to_console no
-- mail spool
-- mail_spool $MAIL
-- Update interval in seconds
	update_interval = 3.0,
-- This is the number of times Conky will update before quitting.
-- Set to zero to run forever.
	total_run_times = 0,
-- Create own window instead of using desktop (required in nautilus)
    own_window = true,
--# If own_window is yes, you may use type normal, desktop or override
--# For Gnome + Openbox or xfdesktop + Openbox combo 
--     own_window_type = 'desktop',
-- own_window_type dock
--# For Gnome and xubuntu (with delay of 20s)
--     own_window_type = 'normal',  
-- For openbox 
	own_window_type = 'override',
-- Class
    own_window_class = 'Conky',
-- Use pseudo transparency with own_window?
	own_window_transparent = true,

--# Required for xubuntu
-- own_window_argb_visual yes
	own_window_argb_value = 0,

-- If own_window_transparent is set to no, you can set the background colour here
-- own_window_colour lightyellow
-- If own_window is yes, these window manager hints may be used
	own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
-- own_window_hints undecorated,below,sticky
-- Use double buffering (reduces flicker, may not work for everyone)
	double_buffer = true,
-- Minimum size of text area
	minimum_width = 340, minimum_height = 5,
--     maximum_width = 350,
-- Draw shades?
	draw_shades = false,
-- Draw outlines?
	draw_outline = false,
-- Draw borders around text
	draw_borders = false,
-- Draw borders around graphs
	draw_graph_borders = true,
-- Stippled borders?
	stippled_borders = 8,
-- border width
	border_width = 20,
-- Default colors and also border colors
	default_color = 'yellow',
	color0 = 'white',
	color1 = 'green',
	color2 = 'red',
	color3 = 'pink',
	default_shade_color = 'grey',
	default_outline_color = 'yellow',
-- Text alignment, other possible values are commented
	alignment = 'top_left',

-- Gap between borders of screen and text
-- same thing as passing -x at command line
	gap_x = 250,
	gap_y = 35,
-- Subtract file system buffers from used memory?
	no_buffers = true,
-- set to yes if you want all text to be in uppercase
	uppercase = false,
-- number of cpu samples to average
-- set to 1 to disable averaging
	cpu_avg_samples = 2,
-- number of net samples to average
-- set to 1 to disable averaging
	net_avg_samples = 2,
-- Force UTF8? note that UTF8 support required XFT
	override_utf8_locale = false,
-- Add spaces to keep things from moving about? This only affects certain
-- objects.
	use_spacer = 'none',
-- Allow each port monitor to track at most this many connections (if 0 or not    set, default is 256)
--max_port_monitor_connections 256
-- Maximum number of special things, e.g. fonts, offsets, aligns, etc.
--max_specials 512
-- Maximum size of buffer for user text, i.e. below TEXT line.
-- max_user_text 16384
-- Buffer is used for intermediary text (can be ..., 1024, 2048, ...) 
	text_buffer_size = 1024,
-- Image cache size
	imlib_cache_size = 0,
-- variable is given either in format $variable or in ${variable}. Latter
-- allows characters right after the variable and must be used in network
-- stuff because of an argument
-- stuff after 'TEXT' will be formatted on screen

--# For background with round corners
-- 	lua_load = './scripts/draw_bg.lua',
-- 	lua_draw_hook_pre = 'draw_bg',

};

-- ${if_running audacious}${execpi 3 ./scripts/conky-music-info.sh}${endif}
conky.text = [[${if_running audacious}\
${execpi 3 ./scripts/music-info.sh}\
${else}\
${if_running mocp}${execpi 3 ./scripts/music-info.sh}\
${endif}${endif}\
]];
