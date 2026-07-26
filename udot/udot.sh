#!/bin/bash

errf() { printf "$@\n" >&2; exit 1; }
# replace '/home/*' with '~' in path for display
tilde_path() { echo "$1" | sed "s#$(realpath ~)#~#"; }

[[ "$EUID" != "0" ]] || errf "==> abort for super user"

SELF_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
SRC_DIR=$SELF_DIR
CONF_DIR=~/.config
mkdir -p $CONF_DIR

test_names() {
   local names=()
   if [[ "$1" == "all" ]]; then
      mapfile -t names < <(find $SRC_DIR -mindepth 1 -maxdepth 1 -type d \
         ! -name ".git" \
         ! -name "kanshi" \
         -exec basename '{}' \;)
      names+=( "bashrc" )
   else
      for n in "$@"; do
         n=${n%/}
         [[ "$n" == "rime" || "$n" == "bashrc" || -d ${SRC_DIR}/${n} ]] \
            || errf "name not found: $n"
         [[ "$n" != "kanshi" ]] && names+=("$n")
      done
   fi
   echo "${names[@]}"
}

install_config() {
   local n="$1"
   if [[ -d ${CONF_DIR}/${n} ]]; then
      rm -rf ${CONF_DIR}/${n}
      echo "==> removed '$(tilde_path ${CONF_DIR}/${n})'"
   fi
   cp -rf ${SRC_DIR}/${n} ${CONF_DIR}/${n}
   echo "==> installed '$(tilde_path ${CONF_DIR}/${n})'"
}

merge_config() {
   local n="$1"
   if [[ -d ${CONF_DIR}/${n} ]]; then
      rm -rf ${SRC_DIR}/${n}
      cp -rf ${CONF_DIR}/${n} ${SRC_DIR}/${n}
      echo "==> merged '$(tilde_path ${SRC_DIR}/${n})'"
   fi
}

install_lite_xl() {
   mkdir -p ${CONF_DIR}/lite-xl
   local path="lite-xl/init.lua"
   cp -f ${SRC_DIR}/${path} ${CONF_DIR}/${path}
   echo "==> installed '$(tilde_path ${CONF_DIR}/${path})'"
}

merge_lite_xl() {
   local path="lite-xl/init.lua"
   cp -f ${CONF_DIR}/${path} ${SRC_DIR}/${path}
   echo "==> merged '$(tilde_path ${SRC_DIR}/${path})'"
}

install_rime_wubi86s() {
   local rime_dir=~/.local/share/fcitx5/rime
   mkdir -p $rime_dir
   cp -f ${SRC_DIR}/rime-wubi86s/*.yaml ${rime_dir}/
   echo "==> installed '$(tilde_path ${rime_dir})/*.yaml'"
}

merge_rime_wubi86s() {
   local rime_dir=~/.local/share/fcitx5/rime
   mapfile -t names < <(find ${SRC_DIR}/rime-wubi86s -type f -name "*.yaml" \
      -exec basename '{}' \;)
   for n in ${names[@]}; do
      if [[ -f ${rime_dir}/${n} ]]; then
         cp -f ${rime_dir}/${n} ${SRC_DIR}/rime-wubi86s/ 
      fi
   done
   echo "==> merged '$(tilde_path ${SRC_DIR}/rime-wubi86s)/*.yaml'"
}

install_rime() { install_rime_wubi86s; }
merge_rime() { merge_rime_wubi86s; }

install_bashrc() {
   if ! grep -q 'sway/bins' ~/.bashrc; then
      cat ${SRC_DIR}/_bashrc >> ~/.bashrc
      echo "==> appended '$(tilde_path ${SRC_DIR}/_bashrc)' to '~/.bashrc'"
   fi
}

merge_bashrc() { return; }

case "$1" in
   install)
      shift
      names=$(test_names "$@")
      [[ -n "$names" ]] || errf "empty names"
      for n in ${names[@]}; do
         case "$n" in
            lite-xl|rime-wubi86s|rime|bashrc)
               install_${n//-/_}
               ;;
            *)
               install_config $n
               ;;
         esac
      done
      ;;
   merge)
      shift
      names=$(test_names "$@")
      [[ -n "$names" ]] || errf "empty names"
      for n in ${names[@]}; do
         case "$n" in
            lite-xl|rime-wubi86s|rime|bashrc)
               merge_${n//-/_}
               ;;
            *)
               merge_config $n
               ;;
         esac
      done
      ;;
   *)
      errf "Usage: $(basename $0) <install|merge>"
      ;;
esac

