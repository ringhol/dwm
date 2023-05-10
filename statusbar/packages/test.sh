get_authorization() {
	resp=$(curl http://localhost:2017/api/login -X POST -d '{"username": "semtor", "password": "010107"}' -H "Content-Type: application/json")
	TOKEN=$(echo $resp | grep -o '"token":"[^"]\+"' | cut -d '"' -f4)
	echo $TOKEN
}

get_authorization
