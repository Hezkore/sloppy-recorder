#!/bin/bash

# Sloppy Recorder
# By Hezkore

# Some adjustable options
QUALITY=25 # The CRF value for ffmpeg (lower is better quality but larger file size)
FRAMERATE=30 # The frame rate for ffmpeg
AUDIO_SOURCE="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor" # The audio source for ffmpeg
# If the audio source is not working, try typing `pactl list sources short` in the terminal to find valid sources.

# Dependency check
missing=0
for cmd in slop ffmpeg yad notify-send; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Error: '$cmd' is not installed. You need to install $cmd."
		missing=1
	fi
done
if [ "$missing" -ne 0 ]; then
	echo "Please press Enter to exit."
	read
	exit 1
fi

# Temporary files
TEMP_FILE="/tmp/sloppy_record_area"
PID_FILE="/tmp/sloppy_record_pid"

# Trap SIGINT (Ctrl+C) to clean up
cleanup() {
	echo "Cleaning up..."
	[ -n "$FFMPEG_PID" ] && kill "$FFMPEG_PID" 2>/dev/null
	[ -f "$PID_FILE" ] && rm -f "$PID_FILE"
	[ -f "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
}
trap cleanup SIGINT

# Check if recording is already in progress
if [ -f "$PID_FILE" ]; then
	# Stop the recording
	FFMPEG_PID=$(cat "$PID_FILE")
	echo "Stopping recording with PID: $FFMPEG_PID"
	kill "$FFMPEG_PID" 2>/dev/null
	rm -f "$PID_FILE"
	exit 0
fi

# Check if we have a saved area
if [ ! -f "$TEMP_FILE" ]; then
	notify-send -u normal -t 5000 "🔲 Select your area" "Use your mouse to select the recording area."
	eval $(slop -c 255,0,0 -b 2 -n -f "geom=%wx%h pos=%x,%y") || exit 1
	
	# Is this a valid screen region or empty?
	if [ -z "$geom" ] || [ -z "$pos" ]; then
		echo "No valid screen region selected."
		notify-send -u normal -t 5000 "❌ No valid screen region selected" "Please try again."
		exit 0
	fi
	# Width and Height must both be greater than 4 pixels
	if [ "${geom%%x*}" -le 4 ] || [ "${geom##*x}" -le 4 ]; then
		echo "Width and Height must be greater than 4 pixels."
		notify-send -u normal -t 5000 "❌ Width and Height must be greater than 4 pixels" "Please try again."
		exit 0
	fi
	
	# Save the selected area to the temporary file
	echo "$geom $pos" > "$TEMP_FILE"
	
	# Was the -r argument passed? If so, do NOT exit
	if [ "$1" == "-r" ]; then
		echo "Starting recording instantly..."
	else
		notify-send -u normal -t 5000 "✅ Area Selected" "Run again to start recording."
		echo "Run again to start recording."
		exit 0
	fi
fi

# Start recording
read geom pos < "$TEMP_FILE"
rm -f "$TEMP_FILE"

echo "Recording screen region: $geom at position: $pos"

# Prepare filename
OUTFILE="$HOME/Videos/recording_$(date +%F_%H-%M-%S).mp4"

# Start ffmpeg in background
ffmpeg -f x11grab -framerate $FRAMERATE -video_size "$geom" -i :0.0+"$pos" \
    -f pulse -i $AUDIO_SOURCE \
    -c:v libx264 -preset veryfast -crf $QUALITY "$OUTFILE" \
    -c:a aac -b:a 96k &
FFMPEG_PID=$!

# Save the PID to the PID file
echo "$FFMPEG_PID" > "$PID_FILE"

# Create tray icon to stop recording
yad --notification --image=media-record \
	--text="Recording..." \
	--command="kill $FFMPEG_PID" &

# Show a notification
notify-send -u normal -t 5000 "🔴 Recording started" "Click tray icon or run again to stop recording."

# Wait for ffmpeg to finish
wait $FFMPEG_PID

# Notify that recording has stopped
notify-send -t 10000 "💾 Recording stopped" "Saved to: $OUTFILE"

# Cleanup
rm -f "$PID_FILE"
kill %yad 2>/dev/null
exit 0