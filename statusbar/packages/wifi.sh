#! /bin/bash

tempfile=$(cd $(dirname $0);cd ..;pwd)/temp

this=_wifi
icon_color="^c#000080^^b#3870560x88^"
text_color="^c#000080^^b#3870560x99^"
signal=$(echo "^s$this^" | sed 's/_//')

# check
[ ! "$(command -v nmcli)" ] && echo command not found: nmcli && exit
# 中英文适配
wifi_grep_keyword="connected to"
wifi_disconnected="disconnected"
wifi_disconnected_notify="disconnected"
if [ `echo $LANG |grep zh_CN` ]; then
    wifi_grep_keyword="已连接 到"
    wifi_disconnected="未连接"
    wifi_disconnected_notify="未连接到网络"
fi

update() {
    wifi_icon=""
    wifi_text=$(nmcli | grep "$wifi_grep_keyword" | sed "s/$wifi_grep_keyword//" | awk '{print $2}' | paste -d " " -s)
    [ "$wifi_text" = "" ] && wifi_text=$wifi_disconnected

    icon=" $wifi_icon "
    text=" $wifi_text "

    sed -i '/^export '$this'=.*$/d' $tempfile
    # printf "export %s='%s%s%s%s%s'\n" $this "$signal" "$icon_color" "$icon" "$text_color" "$text" >> $tempfile
    printf "export %s='%s%s%s'\n" $this "$signal" "$icon_color" "$icon"  >> $tempfile
}

notify() {
    update
    notify-send -r 9527 "$wifi_icon Wifi" "\n已连接到: <span color='#00BFFF'>$wifi_text</span>"
}

call_nm() {
    pid1=`ps aux | grep 'kitty -t statusutil' | grep -v grep | awk '{print $2}'`
    pid2=`ps aux | grep 'kitty -t statusutil_nm' | grep -v grep | awk '{print $2}'`
    mx=`xdotool getmouselocation --shell | grep X= | sed 's/X=//'`
    my=`xdotool getmouselocation --shell | grep Y= | sed 's/Y=//'`
    kill $pid1 && kill $pid2 || st -t statusutil_nm -g 60x25+$((mx - 240))+$((my + 20)) -c FGN -C "#222D31@4" -e 'nmtui-connect'
}

show_menu(){
  notify-send -r 9527 "扫描Wi-Fi中..."
  wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/  */ /g' | sed -E "s/WPA*.?\S/ /g" | sed "s/^--/ /g" | sed "s/  //g" | sed "/--/d")

  connected=$(nmcli -fields WIFI g)
  if [[ "$connected" =~ "enabled" ]]; then
    toggle="睊  Disable Wi-Fi"
  elif [[ "$connected" =~ "disabled" ]]; then
    toggle="直  Enable Wi-Fi"
  fi

  chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " )

  chosen_id=$(echo "${chosen_network:3}" | xargs)

  if [ "$chosen_network" = "" ]; then
    exit
  elif [ "$chosen_network" = "直  Enable Wi-Fi" ]; then
    nmcli radio wifi on
  elif [ "$chosen_network" = "睊  Disable Wi-Fi" ]; then
    nmcli radio wifi off
  else
    success_message="成功连接到WiFi: \"$chosen_id\"."
    saved_connections=$(nmcli -g NAME connection)
    if [[ $(echo "$saved_connections" | grep -w "$chosen_id") = "$chosen_id" ]]; then
      nmcli connection up id "$chosen_id" | grep "成功" && notify-send -r 9527 "wifi已连接" "$success_message" && exit
    fi
    if [[ "$chosen_network" =~ "" ]]; then
      wifi_password=$(rofi -dmenu -p "密码: " )
    fi
    nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "成功" && notify-send  -r 9527 "wifi已连接" "$success_message"
  fi
}

click() {
    case "$1" in
        L) notify ;;
        R) show_menu ;;
    esac
}

case "$1" in
    click) click $2 ;;
    notify) notify ;;
    *) update ;;
esac
