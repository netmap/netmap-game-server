# Game Server VM Use Instructions

This document contains step-by-step instructors for using a prebuilt VM that
matches the game server's production environment.


## Setup

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). If you have
Linux, your package repositories have it.

2. Install sshfs from your Linux distribution's package repositories. If you
have OSX, install the two packages on the
[FUSE for OSX page](http://osxfuse.github.com/).

3. Download the VM and import it into VirtualBox.

4. Start the VM.

5. Create an SSH key, if you don't have one.

    ```bash
    ssh-keygen -t rsa
    # press Enter all the way (default key type, no passphrase)
    ```

6. If you created an SSH key,
   [upload it to the Git hosting service](https://git.pwnb.us/_/ssh_keys/new).

7. Set up public key SSH login and verify that it works.

    ```bash
    ssh-copy-id netmap@netmap.local
    ssh netmap@netmap.local
    # ssh should not ask for a password.
   ```

8. Personalize SSH, so you can make commits on the server.

    ```bash
    # ssh netmap@netmap.local
    git config --global user.name "Victor Costan"
    git config --global user.email costan@gmail.com
    ```

## General Use

1. Mount the homedir on the server over SSHFS.

    ```bash
    mkdir netmap-server
    sshfs netmap@netmap.local: netmap-server
    ```

2. Start the game server.

    ```bash
    # ssh netmap@netmap.local
    cd ~/netmap
    foreman start
    ```

3. Access the server at [http://netmap.local:9000/](http://netmap.local:9000/)
