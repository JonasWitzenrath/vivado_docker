# Using the docker containter to synthesize and implement vivado projects

## granting yourself ssh-access to the container

**NOTE: This section is most likely to be changed. If so, the following is adjusted accordingly.**
If you don't already have on, generate yourself an ssh-key that is **not** protected by a password. That's because Vivado can't handle password requests. (_note: maybe agent forwarding is useful here_)
```shell
ssh-keygen -t rsa -b 4096 -C <name_for_the_key>
```
Then copy the public part to the server
```shell
scp </path/to/key.pub> <user>@<server>:
```
Log onto the server and append the key to the authorized keys of the container (root-privileges requiered)
```shell
sudo -i
cat ~/key.pub >> </path/to/vivado-ssh/authorized_keys>
rm ~/key.pub
logout
```
Reload the ssh deamon of the container
```shell
docker exec -it <vivado_container> service ssh restart
```

Now you are able to log onto the container using your key
```shell
ssh root@<server> -p <exposed_port> -i </path/to/key>
```
Accept the fingerprint by typing `yes` and you should be greeted by a prompt like
```shell
root@3a33a1da3017:/#
```
whith some other hostname. Log out of the container.

## Sharing files with the server
In order for the remote synthesis to work properly it is necassary that your vivado project is located in exactly the same location on the server and your local machine. The most convenient option is to store the files on the server and mount them as a remote filesystem to your client which also ensures maximum speed. One option is sshfs. This gives the added benefit of not having to worry about server-side file location since there is a suitable directory mounted into the container and can be accessed at `/usr/share/vivado-projects` in the container. Because the container uses openSSH, it is already setup to be used with sshfs.

#### setup sshfs on ubuntu
Make sure the package list is up-to-date dant install sshfs
```shell
sudo apt update & sudo apt install sshfs
```
Then create a mountpoint. It is important to use this exact location in order for the remote synthesis to work properly.
```shell
sudo mkdir /usr/share/vivado-projects
sudo chown <user>:<user_group> /usr/share/vivado-projects
```
and mount the external directory
```shell
sshfs root@<server>:/usr/share/vivado-projects /usr/share/vivado-projects/ -o IdentityFile=</path/to/key> -p <exposed_port>
```
If all went well you should now see some files in `/usr/share/vivado-projects`.

## Setup Vivado
+ Open Vivado and create your new project in `/usr/share/vivado-projects` or copy an existing project to this location prior to opening it in vivado.
+ With the project open, in the sidebar under _Project Manager_ select _Settings_.
+ Expand _Remote Hosts_ (left sidebar, second to last entry) and click on _Manual Configuration_.
+ Click the _Add…_ button and enter the server's address.
+ Then allow more than one job, e.g . 6.
+ Modify the _Launch Jobs_ commend to
  ```shell
  ssh -q -p <exposed_port> -l root -i </path/to/your/key> -o BatchMode=yes
  ```
+ Click the _Test_ button to verify vivado can communicate with the server. If this is not the case and you get an error like "Connection failed" but you have been able to ssh into the container via a terminal, then you also need to alter `/bin/sh`. Vivado does not work with dash, the default shell interpreter of ubuntu; therefore exchange it with bash:
  ```shell
  sudo ln -sf /bin/bash /bin/sh
  ```
  Try the _Test_ button again. It shpuld now work.
+ Now just select _Launch runs on remote hosts_ when starting the synthesis/implementation.
