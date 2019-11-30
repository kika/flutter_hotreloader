---
title: How to automatically hot reload Flutter when Dart source files change
date: '2018-12-01T23:54:48.507Z'
categories: []
keywords: []
---
# Flutter hotreloader
Automatically reloads or restarts `flutter run` session(s)

## Run

 1. Run as manu flutter sessions as you like with `--pid-file /tmp/flutterXXX.pid` option, where XXX might be anything, but different for each session.
 2. Start the `hotreload.sh` script


The `hotreloader.sh` helper script receives the full path of the changed file as the first argument. You may want to adjust the regular expression to match your paths so that hotreloader knows when to hot reload and when to hot restart the flutter.
My version hot restarts every time the path contains `.../state/...`.

## Original Medium post from my blog


`brew install entr` or use your OS package manager. Or go to [http://eradman.com/entrproject/](http://eradman.com/entrproject/)

`flutter run -d <your device id> --pid-file /tmp/flutter.pid`

```
cd yourprojectdir
```

```
find lib/ -name '*.dart' | \    entr -p kill -USR1 $(cat /tmp/flutter.pid)
```

Bingo.

What does it do: `entr` reads a list of files from standard input and starts watching them for changes. Once it detects the change it executes a command passed to its command line. Flutter reacts to `SIGUSR1` signal and hot reloads.

Although there’s a drawback in this simplistic approach: if you add a new Dart file and start making changes to it, the script above will not notice it. Because the list of files is created once at the start of the script and then fed to `entr` which then monitor them. If you need free white glove new files delivery do the following:

```
while true  
do  
    find lib/ -name '*.dart' | \  
        entr -d -p kill -USR1 $(cat /tmp/flutter.pid)  
done
```

The option `-d` will make `entr` exit every time a new file is detected in all the directories fed to it in the first place (in this case within `lib/` hierarchy). And then the `while` loop will just restart the process all over again, scanning all the files and adding them to `entr`.

I actually use a more complex setup, because I use Redux in the project and hot reload doesn’t work good with changes to some redux related files (like middleware and such). So I call hot restart `(SIGUSR2)` for files related to state, and hot reload `(SIGUSR1)` for the rest.

Instead of `kill` I use a script, called `hotreloader.sh` which determines what type of file was changed and does the proper `kill` to cause either hot restart or hot reload

```
#!/bin/bash  
set -euo pipefail  
PIDFILE="/tmp/flutter.pid"

if [[ "${1-}" != "" && -e $PIDFILE ]]; then  
    if [[ "$1" =~ \/state\/ ]]; then  
        kill -USR2 $(cat $PIDFILE)  
    else  
        kill -USR1 $(cat $PIDFILE)  
    fi  
fi
```

And then I use the variation of the command above to start `entr` :

```
while true
do
    find lib/ -name '*.dart' | \
        entr -d -p ./hotreloader.sh /_
done
```
