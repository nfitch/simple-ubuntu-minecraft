# Introduction

On Ubuntu, with systemd, manage a set of Minecraft servers.  Only one
will run at a time.  The goal was to make the management as simple as
possible.

# Getting started

## Some prerequisites

### java

    $ sudo apt-get install openjdk-20-jre-headless

### mcrcon

These scripts assume that `mcrcon` is under
`$REPO/tools/mcrcon/mcrcon`.  The install script will try to download
and compile it for you, but if that doesn't work try it manually:

    $ mkdir tools && cd tools
    $ git clone https://github.com/Tiiffi/mcrcon.git
    $ cd mcrcon && gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c

See: https://www.shells.com/l/en-US/tutorial/0-A-Guide-to-Installing-a-Minecraft-Server-on-Linux-Ubuntu

## Get this repo and run setup

    $ git clone ...
    $ sudo ./bin/mserver_install.sh

## Create and run your first Minecraft Server

As the minecraft user:

    $ ./bin/mserver_new.sh -n foo
    $ ./bin/mserver_switch.sh -n foo
    $ ./bin/mserver_start.sh

## Create another, swith to it, run it

    $ ./bin/mserver_stop.sh
    $ ./bin/mserver_new.sh -n bar
    $ ./bin/mserver_switch.sh -n bar
    $ ./bin/mserver_start.sh

# mcmap Integration

This has some hooks for you to generate maps you can view in a web browser using mcmap (https://github.com/spoutn1k/mcmap).

First, install mcmap under `tools`:

    $ apt update && apt install git make g++ libpng-dev cmake libspdlog-dev
    $ cd tools
    $ git clone https://github.com/spoutn1k/mcmap
    $ mkdir -p mcmap/build && cd mcmap/build
    $ cmake ..
    $ make -j

Then you can render a single map to a location:

     $ ./mserver_mcmap.sh -n foo -o ./maps
     $ ls maps
     foo
     $ ls maps/foo
     index.html     output


# Commands to remember

Adding someone to the whitelist:

    $ ./bin/mserver_rcon.sh
    >whitelist add <username>

You can have them join and check the logs for their username when they
are rejected (`systemctl status minecraft` gives the last few lines).

# systemd command reminders
    $ sudo systemctl start minecraft
    $ sudo systemctl stop minecraft
    $ sudo systemctl status minecraft
    $ sudo journalctl -u minecraft

    $ sudo systemctl enable minecraft
    $ sudo systemctl disable minecraft

# References

* https://askubuntu.com/questions/1198585/how-to-i-make-a-program-start-on-boot-no-gui
* https://gist.github.com/chungy/0b2c438c7db90b32701a
* https://www.shells.com/l/en-US/tutorial/0-A-Guide-to-Installing-a-Minecraft-Server-on-Linux-Ubuntu

# License

MIT.  See LICENSE.
