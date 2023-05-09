power_on() {
	if bluetoothctl show | grep -q "Powered: yes"; then
		return 0
	else
		return 1
	fi
}
print_status() {
	if power_on; then
		info=' 已配对的设备
    '
		paired_devices_cmd="devices Paired"
		# Check if an outdated version of bluetoothctl is used to preserve backwards compatibility
		if (($(echo "$(bluetoothctl version | cut -d ' ' -f 2) < 5.65" | bc -l))); then
			paired_devices_cmd="paired-devices"
		fi
		mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
    if [ ${#paired_devices[@]} -eq 0 ]; then
      info="$info 无"
      break
    fi
		for device in "${paired_devices[@]}"; do
			if device_connected $device; then
				device_alias=$(bluetoothctl info $device | grep "Alias" | cut -d ' ' -f 2-)
        info="$info
        $device_alias"
			fi
		done
	else
		info='󰂲 蓝牙未开启'
	fi
	notify-send "$info" -r 9527
}

print_status
