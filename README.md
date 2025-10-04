# Cheburashka
Scripting some conveniences for home theater setup.

## Motivation
I have a DIY sound system. It is not very good. Thus I configured Voicemeeter Banana to cross frequencies between it and TV, outputting sound to both at the same time. But it meant that I had to launch Banana and switch sound output device every time I want to watch something on a big screen. So I wrote a script to do this in one click. Then I figured I need a remote to pause the player or to quickly switch to next episode. So I wrote another script. Then I kinda merged them in one blob.

## Details
### `banana_launcher.ps1`
Launches Banana, launches the remote, swtiches sound output device, hides Banana's windows by some win32 API magic. Creates a small window with remote's address in QR. When window is closed, does the cleanup. Depends on some audio interfaces managing module for PS that I forgot the name of.

### `banana_launcher.ink`
This is what resides on my desktop to be quickly doubleckicked when needed.

### `remote_control/remote.rb`
A webrick web server that also sends keyboard function keys messages via user32 API, and returns filename for QR code of the address of the web page served, which is `http://local IP:8123`. Depends on `rqrcode` to generate said QR code.

### `remote_control/remote.html`
Dumb little remote with basic buttons.

### `remote_control/192.168.0.105.png`
Example of QR code file.

