# Game Server VM Setup Instructions

This document contains step-by-step instructions for building a
VM that matches the game server's production environment.


1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). If you have
Linux, your package repositories have it.

2. Install sshfs from your Linux distribution's package repositories. If you
have OSX, install the two packages on the
[FUSE for OSX page](http://osxfuse.github.com/).

3. Download the
[Ubuntu 12.10 Server 64-bit ISO](http://releases.ubuntu.com/quantal/ubuntu-12.10-server-amd64.iso).

4. Set up a VirtualBox VM.
    * Name: NetmapServer
    * Type: Linux
    * Version: Ubuntu 64-bit
    * RAM: 1024Mb
    * Disk: VDI, dynamic, 16Gb

5. Change the settings (Machine > Settings in the VirtualBox menu)
    * Audio > uncheck Enable Audio
    * Network > Adapter 1 > Advanced > Adapter Type: virtio-net
    * Network > Adapter 2
        * Check Enable network adapter
        * Attached to > Host-only Adapter
        * Advanced > Adapter Type: virtio-net
    * Ports > USB > uncheck Enable USB 2.0 (EHCI) Controller

6. Start VM and set up the server.
    * Select the Ubuntu ISO downloaded earlier.
    * Start a server installation, providing default answers, except:
        * Hostname: netmap
        * Full name: netmap
        * Username: netmap
        * Password: netmap
        * Confirm using a weak password
        * Encrypt home directory: no
        * Partitioning: Guided - use entire disk (no LVM or encryption)
        * Software to install: OpenSSH server

7. After the VM restarts, set up networking.
    * Log in using the VM console. (the username and password are netmap)
    * Open `/etc/network/interfaces` in a text editor e.g.,
        `sudo vim /etc/network/interfaces`
    * Create a duplicate of the "primary network interface" section
    * In the duplicate section, replace-all `eth0` with `eth1` and
      `primary` with `secondary`
    * Save the file.

8. Set up mDNS.
    * `sudo apt-get install -y avahi-daemon`

    * Open `/etc/avahi/avahi-daemon.conf` in a text editor e.g.,

        ```bash
        sudo vim /etc/avahi/avahi-daemon.conf
        ```

    * Search for the following variables, and set their values as below.

        ```
        use-ipv4=yes
        use-ipv6=no
        allow-interfaces=eth1
        deny-interfaces=eth0
        publish-aaaa-on-ipv4=no
        ```

    * `sudo reboot`

    * Minimize the VM console

9. Check that networking works by SSH-ing into the server from your Terminal.

    ```bash
    ssh netmap@netmap.local
    # The password is netmap.
    ```

10. Set up the server.

    ```bash
    # ssh netmap@netmap.local
    curl -fLsS https://git.pwnb.us/netmap/netmap-server/raw/master/doc/vm-server-update.sh | sh
    ```

11. Shut down the VM if you want to back up the disk image.

    ```bash
    # ssh netmap@netmap.local
    sudo poweroff
    ```

12. Follow the instructions in `vm-server-use.md` for development.
