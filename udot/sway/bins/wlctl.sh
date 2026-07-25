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
      str+="$(scratchpad-count)"
      str+="$(muted-label)"
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
   pidof swaylock || swaylock \
      --daemonize \
      --ignore-empty-password \
      --indicator-idle-visible \
      --indicator-radius 50 \
      --indicator-thickness 13 \
      --indicator-x-position 80 \
      --indicator-y-position 80 \
      --color 000000 \
      --scaling solid_color
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

terminal() {
   if command -v foot &>/dev/null; then
      foot
   elif command -v alacritty &>/dev/null; then
      alacritty
   fi
}

dynamic_menu() { wmenu-run -b -f 'monospace bold 18' "${@}"; }

app_launcher() { fuzzel; }

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
