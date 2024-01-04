#! /bin/bash
# ICONS 部分特殊的标记图标 这里是我自己用的，你用不上的话去掉就行

tempfile=$(
	cd $(dirname $0)
	cd ..
	pwd
)/temp

this=_icons
color="^c#2D1B46^^b#5555660x66^"
signal=$(echo "^s$this^" | sed 's/_//')

with_headphone() {
	[ ! "$(command -v amixer)" ] && echo command not found: amixer && return
	[ "$(amixer -c 0 get Headphone | grep -o '\[on\]')" ] && icons=(${icons[@]} "󰋋")
}

#petition() {
#	text="$(curl -m 2 http://www.ggapi.cn/api/qiuqian)"
#	if [ $? -ne 0 ]; then
#		return
#	fi
#  poem1="<span color='#F0E68C'>󰇹 </span><span color='#7FFFD4'>$(echo $text | sed 's/【解签】.*//')</span>\n"
#  poem2="<span color='#FF69B4'> </span><span color='#00BFFF'>【解签】$(echo $text | sed 's/.*【解签】//')</span>"
#	notify-send '󰖨 每日一签' "$poem1$poem2" -r 10107 -t 20000
#}

update() {
	icons=("󰔉")
	with_headphone
	text=" ${icons[@]} "
	sed -i '/^export '$this'=.*$/d' $tempfile
	printf "export %s='%s%s%s'\n" $this "$signal" "$color" "$text" >>$tempfile
}

notify() {
	texts=""
	# [ "$(bluetoothctl info 88:C9:E8:14:2A:72 | grep 'Connected: yes')" ] && texts="$texts\n WH-1000XM4 已链接"
	[ "$(amixer -c 0 get Headphone | grep -o '\[on\]')" ] && texts="$texts\n󰋋 耳机已连接"
	[ "$texts" != "" ] && notify-send " Info" "$texts" -r 9527 -t 1000
}

# call_menu() {
#     case $(echo -e ' 关机\n 重启\n 休眠\n 锁定' | rofi -dmenu -window-title power) in
#         " 关机") poweroff ;;
#         " 重启") reboot ;;
#         " 休眠") systemctl hibernate ;;
#         " 锁定") ~/scripts/blurlock.sh ;;
#     esac
# }

leftclick() {
	notify
	#petition
}

click() {
	case "$1" in
	L) leftclick ;;
	R) feh --randomize --bg-fill ~/Pictures/wallpaper/*.png ;;
	esac
}

case "$1" in
click) click $2 ;;
notify) notify ;;
*) update ;;
esac
