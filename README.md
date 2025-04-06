# Sloppy Recorder
A quick and dirty screen recorder for Linux and X11 using slop, ffmpeg, yad and notify-send.

# Installation & Usage
Make sure you have the following dependencies installed:
- `slop` for area selection
- `ffmpeg` for video & audio recording
- `yad` for system tray icon
- `notify-send` for notifications

Once they're installed, you can clone this repo and make the `record.sh` script executable:
```bash
chmod +x record.sh
```

Then just go into your desktops settings and bind a key to run the script _(I have mine set to <kbd>Ctrl</kbd>+<kbd>F2</kbd>)_.

Running the script will ask you to select a window or area to record.\
Once selected, you will get a notification that area has been selected, and running the script again will start the recording.\
While recording, you can either click the tray icon or run the script a final time to stop and save the recording.

If you want to record instantly after selecting the area, you can use the `-r` flag when running the script.

Recorded videos will be saved `~/Videos/` with the name `recording_<date_time>.mp4`.

A couple of options can be found in the script itself, such as audio source, CRF and frame rate.