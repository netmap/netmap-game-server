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
    * Name: ChromeWebView
    * Type: Linux
    * Version: Ubuntu 64-bit
    * RAM: 1024Mb
    * Disk: VDI, dynamic, 10Gb

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

10. Install the game server dependencies.

    ```bash
    # ssh netmap@netmap.local
    sudo sh -c "echo netmap ALL=NOPASSWD: NOPASSWD: ALL >> /etc/sudoers"
    sudo apt-get update && sudo apt-get -y dist-upgrade
    sudo apt-get install -y build-essential git libpq-dev libsqlite3-dev \
        postgresql postgresql-client postgresql-contrib \
        postgresql-server-dev-all \
        ruby ruby-dev software-properties-common sqlite3
    sudo env REALLY_GEM_UPDATE_SYSTEM=1 gem update --system 1.8.25
    sudo gem pristine --all
    sudo gem install bundler foreman therubyracer
    ```

11. Install game server dependencies from PPAs.

    ```bash
    # ssh netmap@netmap.local
    sudo add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable  # postgis 2.0
    sudo add-apt-repository -y ppa:kakrueger/openstreetmap  # osm2pgsql 0.81
    sudo add-apt-repository -y ppa:mapnik/v2.1.0
    sudo apt-get update && sudo apt-get -y dist-upgrade
    sudo apt-get install -y libmapnik-dev mapnik-utils osm2pgsql postgis \
        osmosis
    sudo gem install ruby-mapnik
    ```

12. Set up PostgreSQL.

    ```bash
    # ssh netmap@netmap.local
    sudo -u postgres createuser --superuser $USER
    createdb $USER
    ```

13. Set up the game server.

    ```bash
    # ssh netmap@netmap.local
    cd ~
    git clone https://git.pwnb.us/netmap/netmap-server.git netmap
    cd ~/netmap
    bundle install
    rake db:create db:migrate db:seed
    ```

14. De-personalize the game server repository.

    ```bash
    # ssh netmap@netmap.local
    cd ~/netmap
    git remote rm origin
    git remote add origin git@git.pwnb.us:netmap-server.git
    ```

15. Follow the instructions in `vm-server-use.md` for development.
