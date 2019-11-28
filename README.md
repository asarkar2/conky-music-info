# conky-music-info
Information on the desktop of the music being played via conky.
The album image is also displayed along with the music information.

Requirements:
Conky, imagemagick and the music player.
Initial upload only supports the following music players: audacious and moc.

Installation:
Download the files to any folder. For example: ${HOME}/.config/conky/
Inside this folder (~/.config/conky/), the directory structure should be as follows:

config/music_info.lua
scripts/music-info.sh

Running:
Run the following commands:

    cd ~/.config/conky/
    conky -c ~/.config/conky/config/music_info.lua & # (Nothing would seem to happen)

Open either audacious or moc (Music on console) to listen to some music and check out the desktop.

Configuration:
Open the file music_info.lua to make any necessary changes to shift the position of the newly created conky.
Other changes necessary would be in the following conky configurations:
own_window_type, own_window_hints.
