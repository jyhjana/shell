#! /bin/sh
### BEGIN INIT INFO
# Provides:          python plant robot
# Required-Start:    $all
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Run /usr/bin/plant_robot_tcp if it exist
### END INIT INFO


PATH=/sbin:/usr/sbin:/bin:/usr/bin

. /lib/init/vars.sh
. /lib/lsb/init-functions

do_start() {
    ln -s lock /var/run/plant_robot_tcp.lock || exit 0
    echo "check file"
	if [ -f /usr/bin/plant_robot_tcp ]; then
        echo "start plant robot tcp server"
		/usr/bin/plant_robot_tcp -D
		ES=$?
		[ "$VERBOSE" != no ] && log_end_msg $ES
		return $ES
	fi
}

case "$1" in
    start)
	do_start
        ;;
    restart|reload|force-reload)
        ps -aux | grep plant_robot_tcp | grep D | awk '{print $2}' | sudo xargs kill -9
		do_start
        ;;
    stop)
		ps -aux | grep plant_robot_tcp | grep D | awk '{print $2}' | sudo xargs kill -9
        ;;
    status)
		ps -aux | grep plant_robot_tcp | grep D
        ;;
    *)
        echo "Usage: $0 start|stop" >&2
        exit 3
        ;;
esac
