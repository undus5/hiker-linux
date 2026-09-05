#!/usr/bin/bash

set -e

errf() { printf "${@}\n" >&2; exit 1; }

test_cmd() {
   local name="$1"
   command -v "$name" &>/dev/null || errf "command not found: ${name}"
}

#################################################################################
# reload wayland compositor
#################################################################################

reload() {
   if [[ -n "${SWAYSOCK}" ]]; then
      swaymsg reload
   fi
   if [[ -n "${LABWC_PID}" ]]; then
      labwc -r
   fi
   if [[ -n "${SWAYSOCK}" || -n "${LABWC_PID}" ]]; then
      wlinit.sh
      pidof kanshi &>/dev/null && sleep 0.1 && kanshictl reload
   fi
}

#################################################################################
# volume control
# https://wiki.archlinux.org/title/WirePlumber
#################################################################################

vol_get() {
   test_cmd wpctl
   local id="$1"
   local info=$(wpctl get-volume ${id})
   local integer=$(echo "$info" | awk -F'[. ]' '{ print $2 }')
   local fraction=$(echo "$info" | awk -F'[. ]' '{ print $3 }')
   local muted=$(echo "$info" | awk -F'[. ]' '{ print $4 }')
   local label=""

   if [[ "$muted" == "[MUTED]" ]]; then
      label="$muted"
   else
      if [[ "$integer" == "1" ]]; then
         label="100%"
      else
         label="${fraction}%"
      fi
   fi
   echo "$label"
}

vol_num() {
   test_cmd wpctl
   if [[ "$1" == "[MUTED]" ]]; then
      echo "0"
   else
      echo "${1:0:-1}"
   fi
}

# https://wiki.archlinux.org/title/Desktop_notifications#Replace_previous_notification
vol_notify() {
   local vol="$1"
   local msg="${2:-Volume}"
   notify-send -a $(basename $0) -t 1000 \
      -h int:value:$vol \
      -h string:x-canonical-private-synchronous:volume \
      "$msg"
}

vol_down() {
   test_cmd wpctl
   per=${1:-5}
   wpctl set-volume @DEFAULT_AUDIO_SINK@ ${per}%-
   local vol=$(vol_num $(vol_get @DEFAULT_AUDIO_SINK@))
   wobctl.sh $vol
   # vol_notify $vol
}

vol_up() {
   test_cmd wpctl
   per=${1:-5}
   wpctl set-volume @DEFAULT_AUDIO_SINK@ ${per}%+
   local vol=$(vol_num $(vol_get @DEFAULT_AUDIO_SINK@))
   wobctl.sh $vol
   # vol_notify $vol
}

mute_toggle_speaker() {
   test_cmd wpctl
   wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
   local vol=$(vol_num $(vol_get @DEFAULT_AUDIO_SINK@))
   wobctl.sh $vol
   # local msg=
   # if [[ "$vol" == "0" ]]; then
   #    msg="Speaker Muted"
   # fi
   # vol_notify "$vol" "$msg"
}

mute_toggle_mic() {
   test_cmd wpctl
   wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

sink_toggle() {
   test_cmd wpctl
   test_cmd jq
   local sinkids=( $(pw-dump | jq '.[]|select(.info.props."media.class"=="Audio/Sink")|.id' | xargs) )
   local currentid=$(wpctl inspect @DEFAULT_SINK@ | head -n 1 | cut -d, -f1 | cut -d' ' -f2)
   local size=${#sinkids[@]}
      local index=-1
      local targetid
      local desc

      for i in "${!sinkids[@]}"; do
         if [[ "${sinkids[$i]}" == "${currentid}" ]]; then
            index=$i
            break
         fi
      done

      index=$(( ${index} + 1 ))
      (( index >= size )) && index=0
      targetid=${sinkids[$index]}
      desc=$(pw-dump | jq -r --argjson id ${targetid} '.[]|select(.id==$id)|.info.props."node.description"')

      wpctl set-default ${targetid}
      notify-send -a $(basename $0) -t 1000 "Audio Sink" "${desc}"
}

#################################################################################
# status bar content
#################################################################################

scratchpad_count() {
   local count=$(swaymsg -t get_tree | grep -c '"scratchpad_state": "fresh"')
   if [[ "$count" =~ ^[1-9]+[0-9]*$ ]]; then
      echo "[ScratchPad: ${count}] "
   fi
}

muted_label() {
   test_cmd wpctl
   local label
   local vol

   vol="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
   if [[ "$vol" =~ MUTED ]]; then
      label="Speaker"
   fi

   vol="$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)"
   if [[ "$vol" =~ MUTED ]]; then
      if [[ -n "$label" ]]; then
         label+=",Mic"
      else
         label="Mic"
      fi
   fi

   if [[ -n "$label" ]]; then
      echo "[Muted:${label}] "
   fi
}

bar_status() {
   local str
   while true; do
      str=""
      str+="$(scratchpad_count)"
      str+="$(muted_label)"
      str+="$(date '+%a %b.%d %H:%M')"
      printf "%s \n" "${str}"
      sleep 0.1
   done
}

#################################################################################
# lock screen, suspend
#################################################################################

lock_screen() {
   test_cmd swaylock
   BG_FILE=$(find ~/Pictures/ -maxdepth 1 -type f -name 'wallpaper-*.png')
   BG_FILE=$(echo $BG_FILE | head -n 1)
   if [[ ! -f $BG_FILE ]]; then
      BG_FILE=$(find ~/.config/sway/ -maxdepth 1 -type f -name 'wallpaper-*.png')
      BG_FILE=$(echo $BG_FILE | head -n 1)
   fi
   if [[ -f $BG_FILE ]]; then
      BG_NAME=$(basename $BG_FILE)
      BG_NAME=${BG_NAME%.*}
      BG_MODE=${BG_NAME#wallpaper-}
      MODES=( stretch fill fit center tile )
      MODE=tile
      for M in ${MODES[@]}; do
         [[ "$BG_MODE" == "$M" ]] && MODE=$M
      done
      BG_ARGS=" --image $BG_FILE --scaling $MODE "
   else
      BG_ARGS=" --color 000000 --scaling solid_color "
   fi
   CMDL="swaylock"
   CMDL+=" --daemonize "
   CMDL+=" --ignore-empty-password "
   CMDL+=" --indicator-idle-visible "
   CMDL+=" --indicator-radius 50 "
   CMDL+=" --indicator-thickness 13 "
   CMDL+=" --indicator-x-position 80 "
   CMDL+=" --indicator-y-position 80 "
   CMDL+=" --ring-color cccccc "
   CMDL+=" --ring-clear-color cccccc "
   CMDL+=" --ring-ver-color cccccc "
   CMDL+=" --ring-wrong-color cccccc "
   CMDL+=" --inside-clear-color cccccc "
   CMDL+=" --inside-ver-color cccccc "
   CMDL+=" --inside-wrong-color cccccc "
   CMDL+=" --key-hl-color 333333 "
   CMDL+=" --bs-hl-color 999999 "
   CMDL+=" --separator-color ffffff "
   CMDL+=$BG_ARGS
   pidof swaylock || $CMDL
}

# lock_suspend() {
#    lock_screen
#    sleep 0.2
#    systemctl suspend
# }

#################################################################################
# screenshot
# https://github.com/OctopusET/sway-contrib
#################################################################################

save_path=~/Pictures/Screenshot.$(date +%y%m%d.%H%M%S).$(date +%N|cut -c1).png

screenshot_fullscreen() {
   test_cmd grim
   grim $save_path
}

screenshot_area() {
   test_cmd grim
   test_cmd grimshot.sh
   grimshot.sh savecopy area $save_path
}

screenshot_window() {
   test_cmd grim
   test_cmd grimshot.sh
   grimshot.sh savecopy window $save_path
}

#################################################################################
# apps
#################################################################################

app_launcher() { fuzzel; }

terminal() {
   if command -v foot &>/dev/null; then
      foot
   elif command -v alacritty &>/dev/null; then
      alacritty
   fi
}

dynamic_menu() {
   if pgrep -x wmenu-run &>/dev/null; then
      pkill -x wmenu-run
   fi
   wmenu-run -b -f 'monospace bold 18' "$@"
}

#################################################################################
# dispatcher
#################################################################################

case "$1" in
   "")
      echo "Usage: $(basename $0) <function_name>"
      echo "function_name:"
      declare -F | awk '{print "  " $3}' | sed 's/-/_/g'
      ;;
   *)
      cmd="$1"; shift
      ${cmd//-/_} "${@}"
      ;;
esac
