#!/bin/bash
set +e

DAEMON_NAME="google-chrome-daemon"
PID_FILE="/tmp/google-chrome.pid"

CHROME_CMD="google-chrome --kiosk"


start() {
    fb_width=$(xwininfo -root | grep Width | cut -d ' ' -f 4)
    fb_height=$(xwininfo -root | grep Height | cut -d ' ' -f 4)

    if [ -z $fb_width ] || [ -z $fb_height ]; then
        zenity --error --text="Failed to find framebuffer size, quitting" --title="Warning!" &
        exit 1
    fi

    daemon --name=$DAEMON_NAME --pidfile=$PID_FILE -- $CHROME_CMD

    while ! wmctrl -l | grep -q "Google Chrome"; do
        sleep 1
    done
    sleep 3

    # resize google-chrome
    wmctrl -r "Google Chrome" -b toggle,fullscreen
    wmctrl -r "Google Chrome" -e 0,0,0,$fb_width,$fb_height
}


stop() {
    daemon --name=$DAEMON_NAME --pidfile=$PID_FILE --stop
}


case $1 in
    start|stop)
        $1
        ;;
    *)
        printf "Usage: chrome.sh {start|stop}\n"
        exit 1
        ;;
esac
