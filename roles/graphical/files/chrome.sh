#!/bin/bash
set +e

DAEMON_NAME="google-chrome-daemon"
PID_FILE="/tmp/google-chrome.pid"

CHROME_CMD="google-chrome"
CHROME_OPTS="--noerrdialogs --disable-plugins --disable-extensions --no-first-run --disable-overlay-scrollbar --no-default-browser-check --disable-session-crashed-bubble --app=http://localhost:6543/display/display.html?deviceid=main"

WINDOW_TITLE="DisplayTrigger"


start() {
    fb_width=$(xwininfo -root | grep Width | cut -d ' ' -f 4)
    fb_height=$(xwininfo -root | grep Height | cut -d ' ' -f 4)

    if [ -z $fb_width ] || [ -z $fb_height ]; then
        zenity --error --text="Failed to find framebuffer size, quitting" --title="Warning!" &
        exit 1
    fi

    daemon --name=$DAEMON_NAME --pidfile=$PID_FILE -- $CHROME_CMD $CHROME_OPTS

    while ! wmctrl -l | grep -q $WINDOW_TITLE
    do
        sleep 1
    done
    sleep 1

    # resize google-chrome
    for prop in sticky maximized_vert maximized_horz hidden fullscreen;
    do
        wmctrl -r $WINDOW_TITLE -b remove,$prop
    done
    wmctrl -r $WINDOW_TITLE -e 0,0,0,$fb_width,$fb_height
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
