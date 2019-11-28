#!/bin/bash

# Script to show the information of the music being played
# via audacious and moc in conky.

# https://stackoverflow.com/questions/1527049/join-elements-of-an-array
function join(){
    local d=$1
    shift
    echo -n "$1"
    shift
    printf "%s" "${@/#/$d}"
}

# Helptext
function helptext(){

    sname="$1"
    au="$2"
    ver="$3"
    eval "declare -a all_players="${4#*=}

    lstplyrs=$(join ', ' "${all_players[@]}")

    echo "Script to be run from conky for the following audio players:"
    echo "$lstplyrs"
    echo "Author: "${au}""
    echo "Version: "${ver}""
    echo ""
    echo "Usage: $sname [options]"
    echo ""
    echo "Options:"
    echo "  -h|help       Show this help and exit."
}

# Get playername
function get_player(){

    all_players=("$@")
    for plyr in "${all_players[@]}"
    do
        if ps -A | grep "$plyr" > /dev/null 2>&1; then
            echo "$plyr"
            return
        fi
    done

    echo "unsupported"
    return
}

function draw_backup(){

    img="$1"

    width=300
    height=300
    bgcolor='white'
    bordercolor='black'
    border=4

    if [ ! -f "${img}" ];then
        convert -size ${width}x${height} xc:${bgcolor} jpg:- | \
            convert - -bordercolor ${bordercolor} -border ${border}x${border} \
            -resize ${width}x${height} \
            "${img}"
    fi

}

function draw_bg(){

    eval "declare -A params="${1#*=}

    width="${params['width']}"
    height="${params['height']}"
    bgcolor="${params['bgcolor']}"
    corners="${params['corners']}"
    opacity="${params['opacity']}"
    music_bg_path="${params['music_bg_path']}"

    # Create the background if the file does not exist
    if [ ! -f "${music_bg_path}" ];then

        # Rectangle with rounded corners
        convert -size ${width}x${height} xc:${bgcolor} png:- | \
        convert - \
            \( +clone  -threshold -1 \
                -draw "fill black polygon 0,0 0,${corners} ${corners},0 \
                fill white circle ${corners},${corners} ${corners},0" \
                \( +clone -flip \) -compose Multiply -composite \
                \( +clone -flop \) -compose Multiply -composite \
            \) +matte -compose CopyOpacity -composite  \
            -alpha on -channel RGBA -evaluate multiply ${opacity} \
            "${music_bg_path}"

        # Lightning effect
        convert "${music_bg_path}" -matte \
            \( +clone -channel A -separate +channel \
            -bordercolor black -border 5 -blur 0x5 -shade 120x30 \
            -normalize -blur 0x1 -fill grey -tint 100 \) \
            -gravity center -compose Atop -composite \
            "${music_bg_path}"

        # Shadow effect
        convert "${music_bg_path}" \
            \( +clone -background black -shadow 60x3+4+4 \) \
            +swap -background none -layers merge +repage \
            "${music_bg_path}"

    fi
}

function get_max_count(){

    eval "declare -A info="${1#*=}

    title="${info['title']}"
    artist="${info['artist']}"
    album="${info['album']}"

    mx_cnt=0
    for value in "${title}" "${artist}" "${album}"
    do
        if [ "${#value}" -gt $mx_cnt ];then
            mx_cnt="${#value}"
        fi
    done

    echo ${mx_cnt}
    return

}

function get_cover(){

    file="${1}"
    eval "declare -A params="${2#*=}

    backup_path="${params['backup_path']}"
    album_cover="${params['album_cover']}"
    pix_folder="${params['pix_folder']}"

    folder=$(dirname "$file")
    folder_img_path="$folder/$album_cover"

    if [ -e "$folder_img_path" ]; then
        mkdir -p "${pix_folder}"
        cp "$folder_img_path" ${pix_folder}
        cover="${pix_folder}/$album_cover"
    else
        draw_backup "${backup_path}"
        cover="${backup_path}"
    fi

    echo ${cover}
    return
}

# Support for audacious
function call_audacious(){

    title="$(audtool current-song-tuple-data title)"
    artist="$(audtool current-song-tuple-data artist)"
    album="$(audtool current-song-tuple-data album)"
    file="$(audtool current-song-filename)"
    totsec="$(audtool current-song-length-seconds)"
    cursec="$(audtool current-song-output-length-seconds)"

    state=$(audtool playback-status)
    state=$(echo ${state^}) # Uppercase 1st letter

    declare -A dict=( ['title']="${title}"
                      ['artist']="${artist}"
                      ['album']="${album}"
                      ['file']="${file}"
                      ['totsec']="${totsec}"
                      ['cursec']="${cursec}"
                      ['state']="${state}"
                      ['player']="Audacious"
                    )

    echo '('
    for key in  "${!dict[@]}" ; do
        echo "['$key']=\"${dict[$key]}\""
    done
    echo ')'

}

# Get moc information for a particular key
function get_mocp_info(){

    key="${1}"
    info_all="${2}"

    value=$(echo "${info_all}" | grep "${key}" | cut -d: -f2 \
            | sed 's/^ //g' | sed 's/ $//g')
    echo "${value}"
    return
}

# Get the moc playing state
function get_mocp_state(){

    m_state="${1}"

    if [ "${m_state}" == 'PLAY' ];then
        echo "Playing"
    elif [ "${m_state}" == 'PAUSE' ];then
        echo "Paused"
    elif [ "${m_state}" == 'STOP' ];then
        echo "Stopped"
    fi

    return
}

# Support for MOCP
function call_mocp(){

    info_all=$(mocp --info)

    mocp_state=$(get_mocp_info "State" "${info_all}")
    state=$(get_mocp_state "${mocp_state}")

    title=$(get_mocp_info "SongTitle" "${info_all}")
    artist=$(get_mocp_info "Artist" "${info_all}")
    album=$(get_mocp_info "Album" "${info_all}")
    file=$(get_mocp_info "File" "${info_all}")
    totsec=$(get_mocp_info "TotalSec" "${info_all}")
    cursec=$(get_mocp_info "CurrentSec" "${info_all}")

    declare -A dict=( ['title']="${title}"
                      ['artist']="${artist}"
                      ['album']="${album}"
                      ['file']="${file}"
                      ['totsec']="${totsec}"
                      ['cursec']="${cursec}"
                      ['state']="${state}"
                      ['player']="MOC"
                    )

    echo '('
    for key in  "${!dict[@]}" ; do
        echo "['$key']=\"${dict[$key]}\""
    done
    echo ')'
}

# Poor man's replacement of moc_bar (not found in conky)
# Since execbar doesn't seem to be working.
function moc_bar(){

    i="$1" # Number of '='
    n="$2" # Total length of the progress bar

    # If $i is null, then exit
    if [ -z "${i}" ]; then
        return
    fi

    # Number of blanks
    j=$(echo "$n-$i" | bc)

    # https://stackoverflow.com/questions/5799303/print-a-character-repeatedly-in-bash/22048085
    printf '|'
    if [ $i -ne 0 ] ; then
        printf '%.0s=' $(seq 1 $i)
    fi
    printf '>'
    printf '%.0s ' $(seq 1 $j)
    printf "|\n"

}

# Crop the title, artist, and album
function crop_string(){

    max_char="$1"
    eval "declare -A dict="${2#*=}

    for key in "${!dict[@]}"
    do
        if [ ${key} == 'title' ] \
          || [ $key == 'artist' ] \
          || [ ${key} == 'album' ]; then
            value="${dict[${key}]}"
            if [ ${#value} -gt $max_char ];then
                value="${value:0:$max_char}""..."
                dict[${key}]="${value}"
            fi
        fi
    done

    echo '('
    for key in  "${!dict[@]}" ; do
        echo "['$key']=\"${dict[$key]}\""
    done
    echo ')'

}

# Print to conky
function print_conky_config(){

    eval "declare -A params="${1#*=}
    eval "declare -A info="${2#*=}

    header_len="${params['header_len']}"
    max_char="${params['max_char']}"
    backup_path="${params['backup_path']}"

    state="${info['state']}"
    player="${info['player']}"
    file="${info['file']}"
    totsec="${info['totsec']}"
    cursec="${info['cursec']}"

    # Get the cropped title, artist, and album as dictionary
    declare -A info=$(crop_string ${max_char} "$(declare -p info)")

    title="${info['title']}"
    artist="${info['artist']}"
    album="${info['album']}"

    # Get cover
    cover=$(get_cover "${file}" "$(declare -p params)")

    # Draw the background
    draw_bg "$(declare -p params)"

    echo -n "\${image ${music_bg_path} -p 0,0}"
    echo "\${image ${cover} -p 9,9 -s 100x100}"
    echo -n "                 "
    echo "\${color}${player}: ${state}"
    echo ""
    echo -n "                 "
    echo "\${color}Title: \${color0}${title}"
    echo -n "                 "
    echo "\${color}Artist: \${color0}${artist}"
    echo -n "                 "
    echo "\${color}Album: \${color0}${album}"
    echo -n "                 "

    if [ "${player}" == "Audacious" ];then
        echo "\${audacious_bar}"
    else

        if [ -n "${totsec}" ];then

            # Seems execbar is broken.
#             progress=$(echo "("${cursec}"*100)/"${totsec}"" | bc)
#             echo "\${execbar echo "$progress"}"

            # Alternative solution for progress bar
            # Their is no moc_bar in conky :(
            total_length=$(echo "$header_len+$max_char" | bc)
            progressbar=$(echo "($cursec*$total_length)/$totsec" | bc)
            moc_bar ${progressbar} ${total_length}

        fi
    fi

}

scriptname=$(basename $0)
audio_players=("audacious" "mocp")
requirements=("convert", "audtool", "bc")
author="Anjishnu Sarkar"
version=2.0

# Declare the parameters
declare -A parameters=( ['pix_folder']="./pix"
                        ['backup']="backup.jpg"
                        ['album_cover']="folder.jpg"
                        ['music_bg']="music_bg.png"
                        ['max_char']=20
                        ['header_len']=9
                        ['width']=354
                        ['height']=120
                        ['bgcolor']='grey'
                        ['opacity']=0.5
                        ['corners']=10
                      )

music_bg_path=""${parameters['pix_folder']}"/"${parameters['music_bg']}""
backup_path=""${parameters['pix_folder']}"/"${parameters['backup']}""

parameters["music_bg_path"]="${music_bg_path}"
parameters["backup_path"]="${backup_path}"

# Loop over the cli arguments
while test -n "$1"
do
    case "$1" in
        -h|--help)  helptext ${scriptname} "${author}" "${version}" \
                        "$(declare -p audio_players)"
                    exit 0
                    ;;

        *)          echo "Undefined parameter passed. Aborting."
                    exit 1
                    ;;
    esac
    shift
done

# Get player name
playername=$(get_player "${audio_players[@]}")

case ${playername} in

    audacious)      declare -A info="$(call_audacious)" ;;

    mocp)           declare -A info="$(call_mocp)" ;;

    unsupported)    echo "No supported audio players found. Aborting."
                    exit 1 ;;
esac

## Print the conky configurations
print_conky_config "$(declare -p parameters)" "$(declare -p info)"

