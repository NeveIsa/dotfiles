#Colors settings
c="%{F#6c71c4}"
e="%{F-}"

# Show the time and date
pdate (){
	var=$(date -u +"%a %d %b | %H:%M")
	echo "$c[$e %{F#FF3322}$var%{F#FFFFFF}$c]$e"
}

# Mixer volume level
vol (){
	#var=$(amixer get Master | awk '$0~/%/{print $4}' | tr -d '[]%')
	echo "$c[$e $var $c]$e"
}

# Battery 
bat (){
	var=$(cat /sys/class/power_supply/BAT*/capacity)
        case $var in
            [0-9])  out="$c$e $var%";;
            [1-7]?) out="$a$e $var%";;
            *)      out="$a$e 100%"
		esac
		echo "$out"
}

# CPU temp
cpu (){
	var=$(sensors | awk '/Core 0/ {print $3}')
	echo "$c[$e $var$c]$e"
}

# RAM management
mem (){
	var=$(free -h | awk '/Mem/ {print $3}')
	echo "$c[$e RAM: $var$c]$e"
}

# Hard drive
drive (){
	var=$(df -h | grep '/$' | awk '{print $5}')
	echo "$c[$e $var $c]$e"
}

# private IP
privip (){
    var=$(ip addr show | grep wl | awk '/inet/ {print $2}')
	echo "$c[$e $var$c]$e"
}

# Public IP
pubip (){
	var=$(curl ifconfig.me 2>/dev/null)
	echo "$c[$e $var$c]$e"
}

# Workspace
work (){
	cur=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
	tot=$(xprop -root _NET_NUMBER_OF_DESKTOPS | awk '{print $3}')
	echo "$c[$e$cur | $c$e$tot$c]$e"
}

# Title
tit (){
	var=$(xdotool getwindowfocus getwindowname)
	echo "$c$var$e"
}







#!/bin/bash
# by Paul Colby (http://colby.id.au), no rights reserved ;)
 
PREV_TOTAL=0
PREV_IDLE=0
DIFF_USAGE=NaN
while true
do
	TOPUSAGE="$(top -b -n 1 | head -8 | tail -1 | awk '{print $9}')"

	HIGHUSE=$(bc -l <<< "$TOPUSAGE > 10")

	if [ "$HIGHUSE" -eq "1" ]; then
	  	TOPPROC="[TOP: $(top -b -n 1 | head -8 | tail -1 | awk '{print $12}')]"
	else
		TOPPROC=""
	fi
	
	#echo $TOPPROC
	#BAR_INPUT="%{l}  $(work) $(tit) %{c}$(pdate) %{r}$(pubip) $(privip) $(mem) [CPU: $DIFF_USAGE%] $(cpu) $TOPPROC [%{F#22FF33}BAT:$(bat)]"
	BAR_INPUT="%{l}  $(work) $TOPPROC  %{c}$(pdate) %{r}$(pubip) $(privip) $(mem) [CPU: $DIFF_USAGE%] $(cpu) %{F#22FF33} [BAT:$(bat)] %{F%FFFFFF}"
	echo $BAR_INPUT
	sleep 1

  # cpu calc
  CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
  unset CPU[0]                          # Discard the "cpu" prefix.
  IDLE=${CPU[4]}                        # Get the idle CPU time.
 
  # Calculate the total CPU time.
  TOTAL=0
  for VALUE in "${CPU[@]}"; do
    let "TOTAL=$TOTAL+$VALUE"
  done
 
  # Calculate the CPU usage since we last checked.
  let "DIFF_IDLE=$IDLE-$PREV_IDLE"
  let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
  let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
  #echo -en "\rCPU: $DIFF_USAGE%  \b\b"
 
  # Remember the total and idle CPU times for the next check.
  PREV_TOTAL="$TOTAL"
  PREV_IDLE="$IDLE"
 
done

