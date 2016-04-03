kodictl
=======
Command-line interface for the Kodi JSON-RPC

Make your Kodi/XBMC do things from the commandline.

Usage
-----

List all available JSON-RPC commands on the Kodi host with ```list```
```
$ kodictl list
Addons.ExecuteAddon : Executes the given addon with the given parameters (if possible)
Addons.GetAddonDetails : Gets the details of a specific addon
Addons.GetAddons : Gets all available addons
Addons.SetAddonEnabled : Enables/Disables a specific addon
Application.GetProperties : Retrieves the values of the given properties
Application.Quit : Quit application
Application.SetMute : Toggle mute/unmute
Application.SetVolume : Set the current volume
AudioLibrary.Clean : Cleans the audio library from non-existent items
AudioLibrary.Export : Exports all items from the audio library
...
```

Specify host with ```-r```, defaults to ```http://localhost:8080/jsonrpc```
```
$ kodictl -r http://localhost:8080/jsonrpc" list
```


Some built-in shortcuts:

- Player.GoTo next in playlist for all active players
```
$ kodictl next
```

- Player.GoTo previous in playlist for all active players
```
$ kodictl previous
```

- Player.PlayPause for all active players
```
$ kodictl playpause
```

- Player.Stop for all active players
```
$ kodictl stop
```

- Player.GetItem for all active players
```
$ kodictl nowplaying
```

- Start music partymode playlist (shuffle)
```
$ kodictl shuffle
```

- List all available shortcuts
```
$ kodictl help
```


Installation
------------
```
git clone https://github.com/vdloo/kodictl && cd kodictl
```

Install the pkg
```
raco pkg install
```

You can run the program like
```
racket main.rkt --help
```

Or build a binary and run that. For global execution put that somewhere in
your path.
```
raco exe -o kodictl.bin main.rkt
```
