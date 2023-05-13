get_authorization() {

	resp=$(curl http://localhost:2017/api/login -X POST -d '{"username": "semtor", "password": "010107"}' -H "Content-Type: application/json")
	_v2ray_auth=$(echo $resp | grep -o '"token":"[^"]\+"' | cut -d '"' -f4)
	echo $_v2ray_auth
	# resp="$(curl http://127.0.0.1:2017/api/v2ray -H 'Authorization: $_v2ray_auth' -X DELETE)"
	resp="$(curl http://127.0.0.1:2017/api/v2ray -H 'Authorization: $_v2ray_auth' -X POST)"

	echo $msg
}
get_authorization
