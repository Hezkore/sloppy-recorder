# Sloppy Recorder
A quick and dirty screen recorder for Linux and X11 using `slop`, `ffmpeg`, `yad`, and `notify-send`.

# Installation & Usage
Ensure you have the following dependencies installed:
- `slop` for area selection
- `ffmpeg` for video and audio recording
- `yad` for the system tray icon
- `notify-send` for notifications

Optional dependencies:
- `xclip` for copying the video to the clipboard after recording
- `xdg-open` for opening the video directory after recording

Once the dependencies are installed, clone this repository and make the `record.sh` script executable:
```bash
chmod +x record.sh
```

Then bind a key in your desktop settings to run the script _(I have mine set to <kbd>Ctrl</kbd>+<kbd>F2</kbd>)_.

Running the script will prompt you to select a window or area to record.\
Once selected, you will receive a notification confirming the area has been selected, and running the script again will start the recording.\
While recording, you can either click the tray icon or run the script one final time to stop and save the recording.

If you want to start recording immediately after selecting the area, use the `-r` flag when running the script.

Recorded videos will be saved in `~/Videos/` with the name `recording_<date_time>.mp4`.

A few options can be configured directly in the script, such as the audio source, CRF, and frame rate.