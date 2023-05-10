#! /bin/bash
_v2ray_auth=''

tempfile=$(
	cd $(dirname $0)
	cd ..
	pwd
)/temp

this=_v2ray
color="^c#2D1B46^^b#5555660x66^"
signal=$(echo "^s$this^" | sed 's/_//')

update() {
	icon="  "
	[ "$(ps -ef | grep -v grep | grep 'v2ray run')" ] && icon="  "
	sed -i '/^export '$this'=.*$/d' $tempfile
	printf "export %s='%s%s%s'\n" $this "$signal" "$color" "$icon" >>$tempfile
}

get_authorization() {
	resp=$(curl http://localhost:2017/api/login -X POST -d '{"username": "semtor", "password": "010107"}' -H "Content-Type: application/json")
	_v2ray_auth=$(echo $resp | grep -o '"token":"[^"]\+"' | cut -d '"' -f4)
	sed -i '/^export '_v2ray_auth'=.*$/d' $tempfile
	printf "export %s='%s'\n" _v2ray_auth "$_v2ray_auth" >>$tempfile
}



notify() {
	line1=" v2ray"
	text=" v2ray未启动，老实在家待着吧"
	[ "$(ps -ef | grep -v grep | grep 'v2ray run')" ] && text=" v2ray已启动，封印已破除～"
	notify-send "$line1" "$text" -r 9527
}

toggle_clash() {
	line1=" v2ray"
  source $tempfile
  [ -z "$_v2ray_auth" ] && get_authorization

	if [ "$(ps -ef | grep -v grep | grep 'v2ray run')" ]; then
		text=" 正在关闭v2ray!"
		curl http://127.0.0.1:2017/api/v2ray -H "Authorization: $_v2ray_auth" -X DELETE &
	else
		text=" 正在打开v2ray!"
		curl http://127.0.0.1:2017/api/v2ray -H "Authorization: $_v2ray_auth" -X POST &
	fi
	notify-send "$line1" "$text" -r 9527
}

open_v2raya(){
  xdg-open "http://127.0.0.1:2017"
}


click() {
	case "$1" in
	L) notify ;;
	R) toggle_clash ;;
	M) open_v2raya ;;
	esac
}

case "$1" in
click) click $2 ;;
notify) notify ;;
*) update ;;
esac
