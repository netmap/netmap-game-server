# Game Server VM Use Instructions

This document contains step-by-step instructors for using a prebuilt VM that
matches the game server's production environment.


## Setup

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Most
Linux distributions have VirtualBox available in their package repositories.

2. Install sshfs. Many Linux distributions have it installed by default, and
most distributions have it in their package repositories. On OSX, install the
two packages on the [FUSE for OSX page](http://osxfuse.github.com/).

3. Download and decompress
   [the server VM image](http://people.csail.mit.edu/costan/netmap/netmap-server-vm.7z)

  * On OSX, a 7z decompression utility is needed, such as
    [Keka](http://www.kekaosx.com/)

4. Add the VM to VirtualBox. (Machine > Add in the VirtualBox menu)

5. Start the VM and wait for it to boot up.

6. Create an SSH key, if you don't have one.

    ```bash
    ssh-keygen -t rsa
    # press Enter all the way (default key type, no passphrase)
    ```

7. [Upload your SSH key to the Git hosting site](https://git.pwnb.us/_/ssh_keys/new).

8. Set up public key SSH login and verify that it works.

    ```bash
    ssh-copy-id netmap@netmap.local
    ssh netmap@netmap.local
    # ssh should not ask for a password.
   ```

9. Personalize SSH, so you can make commits on the server.

    ```bash
    # ssh netmap@netmap.local
    git config --global user.name "Your Name"
    git config --global user.email your_name@mit.edu
    ```

10. Update the server software.

    ```bash
    # ssh netmap@netmap.local
    ~/netmap/doc/vm-server-update.sh
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
