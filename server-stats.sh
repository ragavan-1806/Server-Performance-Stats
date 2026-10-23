
#!/bin/bash

echo "========================================"
echo "       LINUX SERVER PERFORMANCE"
echo "========================================"

echo ""
echo "========== SYSTEM INFORMATION =========="
echo "Hostname : $(hostname)"
echo "OS       : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')"
echo "Kernel   : $(uname -r)"
echo "Uptime   : $(uptime -p)"
echo "Load Avg : $(cat /proc/loadavg | awk '{print $1, $2, $3}')"

echo ""
echo "============ CPU USAGE ================="

read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat
total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle1=$((idle + iowait))

sleep 1

read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat
total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle2=$((idle + iowait))

awk -v t=$((total2-total1)) -v i=$((idle2-idle1)) \
'BEGIN {
    if (t > 0)
        printf "Total CPU Usage: %.2f%%\n", (t-i)*100/t
    else
        print "CPU usage unavailable"
}'

echo ""
echo "=========== MEMORY USAGE ==============="

free -m | awk '/^Mem:/ {
    total=$2
    available=$7
    used=total-available
    printf "Total Memory : %d MB\n", total
    printf "Used Memory  : %d MB (%.2f%%)\n", used, used*100/total
    printf "Free Memory  : %d MB (%.2f%%)\n", available, available*100/total
}'

echo ""
echo "============ DISK USAGE ================"

df -P -B1 / | awk 'NR==2 {
    total=$2
    used=$3
    free=$4
    printf "Filesystem   : %s\n", $1
    printf "Total Disk   : %.2f GB\n", total/1024/1024/1024
    printf "Used Disk    : %.2f GB (%.2f%%)\n", used/1024/1024/1024, used*100/total
    printf "Free Disk    : %.2f GB (%.2f%%)\n", free/1024/1024/1024, free*100/total
}'

echo ""
echo "======= TOP 5 PROCESSES BY CPU ========="

ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

echo ""
echo "====== TOP 5 PROCESSES BY MEMORY ======="

ps -eo pid,comm,%mem --sort=-%mem | head -n 6

echo ""
echo "=========== LOGGED IN USERS ============"

who

echo ""
echo "========================================"
echo "          REPORT COMPLETED"
echo "========================================"
