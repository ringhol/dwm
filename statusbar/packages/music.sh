#! /bin/bash
# music 脚本

tempfile=$(cd $(dirname $0);cd ..;pwd)/temp

this=_music
icon_color="^c#3B102B^^b#6873790x88^"
text_color="^c#3B102B^^b#6873790x99^"
signal=$(echo "^s$this^" | sed 's/_//')

[ ! "$(command -v playerctl)" ] && echo command not found: mpc && return

update() {
    music_text="$(playerctl metadata title)"
    if [ $? -ne 0 ];then
      music_text="$(playerctl metadata xesam:url)"
    fi

    icon=" 󰝚 "
    if $music_text=~"\""; then
        text=$(echo $music_text | sed -e "s/\"\\\\\"/g")
    else
        text=" $music_text "
    fi
    [ "$(playerctl status | grep "Paused")" ] && icon=" 󰐎 "
    [ "$(playerctl status | grep "Stopped")" ] && icon=" 󰐎 "

    sed -i '/^export '$this'=.*$/d' $tempfile
    [ ! "$music_text" ] && return
    printf "export %s=\"%s%s%s%s%s\"\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
}

notify(){
  name="$(playerctl metadata title)"
  if [ $? -ne 0 ];then
    name="$(playerctl metadata xesam:url)"
  fi

  text="󰝚  正在播放：
  $name"
  album="$(playerctl metadata album)"
  [ "$album" ] && text="$text 
  专辑:$album"
  artist="$(playerctl metadata artist)"
  [ "$artist" ] && text="$text 
  艺人:$artist"
  notify-send -r 9527 "$text"


}

click() {
    case "$1" in
        L) notify ;;
        R) playerctl play-pause;;
        U) playerctl previous;;
        D) playerctl next ;;
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac
