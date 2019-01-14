# Linux Academy LFCSA Notes


NOTE: These notes are *NOT EXHAUSTIVE* and are just meant to be a record of
what gaps in my knowledge are.

## General notes

Linux is a CaSe Sensitive FILESYSTEM.  So:
`test.txt` is a different file than `TEST.txt`


## Search for files
Using the `find` command with:
- `-type c` looks for all character devices
- `-type l` finds all links in the specified location
- `-type d` finds all directories in the specified location
- `-type f` finds all files in the specified location
- `-size` will filter on the size of a file
  - TODO: Reference `man` documentation for the different metrics used for the
  `-size` parameter
- `-mtime #` finds files that were created based on a specified number of days
  - A positive number looks for files older (greater than) # day(s) ago
  - A negative number looks for files younger (less than) # day(s) ago
  - TODO: Reference `man` documentation for time metrics
- `-name` allows for a regex to filter results
- `-user <userName>` finds items owned by the specified user
- `-perms ###` finds all files that match the permissions for owner/group/world
- `-exec <commandToRun> {} \;` will execute a command against all items found
  using `find`


Using the `locate` command:
- `updatedb` needs to be run to refresh the index of the file system
- `locate` is less flexible in its utility
  - It is more beneficial to learn to use `find`

## File system features and options

### Journaling
- Designed to prevent data corruption from crashes or power loss
- Adds a bit of overhead to file writes
- Some high-performance servers might not necessarily need it
- Often not used on removable media such as removable flash drives

### Ext file system timeline
- Ext (Extended File System)
  - Introduced in 1992
- Ext2
  - First file system to support extended file attributes (x-attrs) and 2TB+ drives
- Ext3
  - Introduced journaling
- Ext4
  - Designed to be backward compatible and introduced some additional features

### BtrFS
- B-Tree File System
- Drive pooling, snapshots, compression, online defragmentation

### ReiserFS
- Introduced in 2001
- Lots of new features that wouldn't be implemented by Ext, such as special
  efficiencies for small text files
- Designed by Hans Reiser
- Unlikely to continue development

### ZFS
- Designed by Sun Microsystems for Solaris
  - Acquired by Oracle
- Drive pooling, snapshots, dynamic disk striping
  - All features BtrFS bring to Linux when it's the default file system
- Each file has a checksum
- Open-sourced under the Sun CDDL license
- Installing ZFS is fairly easy on any Linux distribution
- Ubuntu offers official ZFS support starting with 16.04
  - Uses it for containers by default

### XFS
- Ported to Linux in 2004
- Similar to Ext4
- Can be enlarged (but not shrunk) on the fly
- Good with large files (like backup servers!)
- Poor with many small files (like web servers!)

### JFS
- Journaled File System
- Developed by IBM
- Low CPU usage
- Good performance regardless of file size
- Partitions can be dynamically enlarged but not shrunk
- Support in most every major distribution
- Not as widely tested in production as Ext4

### Swap
- Not used as an actual file system - virtual memory
- Scratch space for stuff that won't fit in RAM
- Hibernating
- Analogous to Windows Paging File

### FAT (FAT16, FAT32, exFAT)
- Microsoft's File Allocation Table file system
- Not Journaled
- Great for USB drives that you'll use on Windows and Apple platforms

## Compare and Manipulate File Content and Use Input-Output redirection
`nl` - Returns file contents with numbered lines prepending each line
- Does not modify the file passed into the command

`cut` - Returns the contents of a file based on a user specified delimiter
- Does not modify the file passed into the command
- Does not do a greedy process by default; matches on first delimiter and will
  return left or right side *of each line* based on user feedback

`fmt` - Simple string formatting command for contents of a file
- Does not modify the file passed into the command

## Analyze text using basic regular expressions
TODO: Return to video for any symbols used for regex strings

## Boot or Change System into Different Operating Modes

### System V Runlevels
0. Halt / Shutdown
1. Single User Mode
2. Multi User Mode w/o Networking (serial connections)
3. Multi User Mode w/ Networking
4. 
5. Multi User Mode w/ Networking and XWindows
6. Reboot
7. 

### Other runlevel management facts
`runlevel` command will show the current host runlevel

To modify the runlevel of a system as a one-off while having access to the local
console, hold the `SHIFT` key, highlight the version you want using the arrow
keys and then hit `e`, find the line the begins with `linux` and then add the
runlevel number and boot the system.

## Install, Configure and troubleshoot bootloaders
The material is scoped to managing `grub2` and the boot configuration lives at:
```sh
/boot/grub/grub.cfg
```

The `grub.cfg` file just mentioned is automatically generated and should not
be directly edited to make changes.  Instead, add templates to:

```sh
/etc/grub.d
```

and settings to:

```sh
/etc/default/grub
```

Running `update-grub` will consume those templates and settings.

The order of the files is handled top-down in the `/etc/grub.d` folder and as
such, the files are commonly prefixed with numbers in the beginning to ensure
the desired processing order.

### Template syntax for Linux Partition

```bash
#!/bin/sh -e
echo "displayed when update-grub is run"
cat << EOF
menuentry "Other Linux Partition" {
    set root=(hd0,3)
    linux /boot/vmlinuz
    initrd /boot/initrd.img
}
EOF
```

### Template syntax for Windows Partition

```bash
#!/bin/sh -e
echo "Adding Windows partition to grub menu"
cat << EOF
menuentry "Windows" {
    set root=(hd2,1)
    chainloader (hd2,1)+1
}
EOF
```

### Bootloader notes
- The string after `menuentry` is what is shown in the grub menu
- The `set root` portion specifies a device by picking the hard disk (zero indexed)
  and then the partition on that selected disk (one indexed)
- The execute bit needs to be set on the new file in `/etc/grub.d`
- `chainloader` is the Windows Boot Partition Manager

NOTE: Check the Grub2 wiki for boot loader troubleshooting in case `grub-install`
is not working to recover a failed boot configuration.

## Dianose and Manage Processes

`top` and `htop` are great resources for this

The default column headers in `top` are identified as follows:
- `PID`: Process ID
- `USER`: User that is running the process
- `PR`: Process Priority
  - Maximum value is `20`
  - Minimum value is `-20`
- `NI`: Nice Value
  - Allows for further priority customization
- `VIRT`: Virtual Memory
- `%CPU`: Percentage CPU utilization
- `%MEM`: Percentage Memory utilization
- `TIME+`: Amount of time the process has been running
- `COMMAND`: The process name

`htop` provides a better presentation of the same information that `top` delivers.

The `ps` command is better suited for automation and discovery.

When no options are provided to `ps`, it returns the processes running by the
current logged in user's session by default.

Using the `kill` command can send signals to processes

`pgrep` will return the PIDs of a pattern provided at runtime.  For example:

```bash
pgrep bash
```
Will return all processes on the system running bash (assuming the user has rights
to read all system processes)

To get a process tree view, run `ps acjf`

`kill -l` will list all the signals that can be sent to a process.  Common ones
include:

- 1 (SIGHUP)
- 9 (SIGKILL)
- 15 (SIGTERM)

To apply a nice level to a process that is going to be executed, run:

```bash
nice -n <niceNumber> <commandToRun>
```

A running process can have its nice value adjusted with `renice`

```bash
renice <niceNumber> <processID>
```

## Locate and Analyze System Log Files

`/var/log/messages` [CentOS] or `/var/log/syslog` [Ubuntu] records general
messages by the system

## Schedule tasks to run at a set date and time

This is the lesson on `crontab`.

`crontab -l` will show scheduled tasks for current user

`crontab -e` will bring up the editor to manage the crontab file

The format for each cron job is:

[minute] [hour] [dayOfMonth] [month] [dayOfWeek] [command]

`*` is used to mark all times for that metric.

A sample task would be:

```crontab
0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
```

At the beginning of the week, tar the `/home/` directory to `/var/backups/home.tgz`
at 5 AM.

The hour column is specified by 24h time and is zero indexed.

Day of the week columin is also zero indexed and starts on Sunday.

## Verify completion of scheduled jobs

Make your own logging mechanism by writing to a file in your script

### Ubuntu
`/var/log/syslog` is the logging location for cron jobs.

Since there isn't a specific logging facility for cron, you'll have to `grep` for
execution in the log file:

```bash
cat /var/log/syslog | grep CRON
```

TODO: Look up where the cron logging lives in CentOS or if there is a way
to use the distro to tell you what logging facility cron jobs are sent to.

## Update software to provide required functionality and security & manage software

***NOTE***:  This is assuming you have root privileges to run most of these
commands.  More specifically, any command that will result in an installation,
upgrade, or removal of packages will often need root.  It is not recommended to
run interactively as root and you'll likely need to `sudo` to elevate privileges
temporary (assuming your user is part of the sudoers on the system)

### Ubuntu/Debian

`dpkg` - used to install Debian packages you already downloaded

`apt-get` - package management, repos, and calculate dependencies

`aptitude` - graphical front-end to apt
- The graphical front end is even extended to the command-line to have
  interactive menus
- Not a scriptable interface; better to use `apt-get` or `dpkg`

#### Common means of discovering packages resident on the system
`dpkg -l` - List installed packages on system

`dpkg -l | grep <packageName>` - List installed packages and pattern match for a
package name

`apt-cache pkgnames` - Lists all the package names that are installed

`apt-cache search <string>` - Returns all the packages that match the string
provided
- This also matches on package description; Is not just matching on package name

`apt-cache show <packageName>` - Returns verbose information about the package
specified

#### apt-get common options
`apt-get update` - Updates the repo package list(s)

`apt-get upgrade` - Upgrades packages installed on the system

`apt-get autoremove` - Removes packages no longer needed on the system

`apt-get dist-upgrade` - Upgrades the current distribution to the latest version
- This is equivalent to going from Windows 10 1803 to Windows 10 1809

`apt-get install <packageNameN>` - If found in configured repos, will install
specified package
- The program will determine what dependencies are missing and install those
  alongside the requested package
- Will accept multiple package names (space separated)

`apt-get remove <packageNameN>` - Uninstalls specified package(s)
- Using `autoremove` after a remove will uninstall the package dependencies
  no longer required for the system, since `remove` does not auto-remove
  package dependencies as part of the uninstall steps

`apt-get purge <packageNameN>` - Removes all components written to disk associated
with the package
- This includes configuration files and the like
- `apt-get remove --purge <packageNameN>` is an equivalent command
  - This is the older method of doing this

`apt-get download <packageNameN>` - Downloads the package specified
- Puts the package in `/etc/apt` folder

`apt-get changelog <packageName>` - Returns the changelog for a package

`apt-get check` - Checks that the dependency tree is healthy

`apt-get build-dep <packageName>` - Downloads the selected package and all of
the dependencies that correspond to it.  It does not install on the system when
executed.
- `/var/cache/apt/archives` is where those packages are downloaded

`apt-get autoclean` - Will clean up the `/var/cache/apt/archives` location so it
does not get bloated with files

### CentOS/RedHat

`rpm` - RedHat Package Manager
- File format for packages on CentOS/RHEL

`yum` - Yellowdog Update Manager
- De facto package manager on CentOS and RHEL

#### yum common options

***NOTE:*** This will largely just list yum commands and not explain what they
do since it will likely mimic what happens in Ubuntu/Debian and the commands
are largely self-describing.  Footnotes will be provided for each command where
there is deviation from the behaviors expressed in Debian/Ubuntu

`yum update`
- Does an update of the repo package information and *upgrade* in a single step

`yum list <packageNameN>`
- `yum list installed` will return all installed packages

`yum search <packageNameN>`

`yum install <packageNameN>`
- The `-y` argument allows for the installation to automatically start without
  user intervention to say yes to accept.

`yum info <packageNameN>`
- Similar to `apt-cache show <packageName>` but for installed packages

`yum list` - Lists all available packages
- This is all *available* packages, not the ones that are installed on the system

`yum grouplist` - Lists application group names to install

`yum groupinstall <groupName>` - Installs all of the packages defined in the
selected application group

`yum repolist` - Shows all of the configured repos on the system
- `yum repolist all` will show all known repos (enabled or disabled)

`yum --enablerepo=<repoName> <packageName>`

`yum clean all` - Cleans up cache

`yum history` - History of actions with yum

#### rpm common commands

`rpm -qpR <rpmFile>` - Queries the package and lists all the package dependencies

`rpm -q <packageName>` - Will return whether the package is installed or not
- `-ql` lists the files installed with the package
- `-qa` lists the install history of all packages on the system

`rpm -qdf <pathToFile>` - Searches documentaion for the file specified

`rpm -Va` - Lists verified packages

`rpm -qa gpg-pubkey*` - Lists the public keys installed for configured repos

`rpm --rebuilddb` - Will rebuild the RPM database in the event it's corrupted

#### Related package commands

`yumdownloader <packageName>` - Downloads the specified package from repo

## Verify the integrity and availability of resources

Evaluating disk and memory consistency;  Covers fsck and memtest86+

`fsck` - File System Consistency Checker

`lsblk` command will enumerate the block devices on the system as well as
partitions and mount points.  It is required to unmount the block device before
`fsck` can be used on a disk.  This can be done with the `umount` command:

```bash
sudo umount /mnt
```

Then provide the devide path to `fsck`:

```bash
sudo fsck /dev/<devId>
```

Putting the file `forcefsck` in the root of the filesystem `/` will force an
`fsck` on next boot.  `fsck` will be ran and `forcefsck` will be deleted

Run memtest86+ either from a live CD or from the boot menu of a Linux install
(if configured)

## Verify the integrity and availablity of key processes

`ps` - Process Status command

`ps -A` - Returns all processes

`ps -e` - Returns all processes (different format)

`ps au` - Returns all processes in a wider and richer format

`ps aux` - Same as `au` but with even more extended information

`ps -ef`

`ps -fU <username>` - List processes of a particular user

`ps -fG <groupname>` - List processes of a particular group

`ps -fp <pID>` - Returns the process specified

`ps -e --forest` - Shows processes with child/parent relationships

`ps -f --forest -C <processName>` -Shows processes of specified process name and
its child/parent relationships

## Change Kernel runtime parameters (persistent and non-persistent)

`sudo sysctl -a` will list all the kernel runtime parameters that exist and are
applied

Also check `/etc/sysctl.d` directory for ways to configure kernel runtime
parameters in a persistent fashion

## Use scripting to automate system maintenance tasks

No notes recorded.

## Scripting conditionals and loops

Variable definitions in bash *do not* require a dollar sign sigil in front.
You do, however, need the leading dollar sign to call the variable

Example:
```bash
#!/bin/bash
DIRECTORY="/home/learning"
echo $DIRECTORY
```

`if` statements in bash are terminated with `fi`

Example:

```bash
#!/bin/bash
DIRECTORY="/home/learning"
if [-d $DIRECTORY] then;
    echo "The directory exists."
else
    echo "The directory does NOT exist."
fi
```

Here's an example of a `for` loop in bash:

```bash
#!/bin/bash
for COUNT in 1 2 3 4 5 6 7 8 9
do
    echo "This is line # $COUNT"
done
```

Here's an example of a `while` loop in bash reading in from a file:

```bash
#!/bin/bash
while read HOST; do
    ping -c 3 $HOST
done < myhosts
```

## Manage the startup process and services (In Services Configuration)

Try and find a `systemctl` tutorial to get better familiar with this management
tool.  I have enough familiarity from banging around in Linux OSes.

## List and identify SELinux/AppArmor file and process contexts

### SELinux (CentOS/RHEL)

`sudo semanage fcontext -l` will show all of the SELinux file contexts

`ls -Z` will show the security context of the current working directory.

`ps auxZ` will show the security context of all processes running

### AppArmor (Debian/Ubuntu)

`sudo aa-status` will show the current status of AppArmor

`/etc/apparmor.d` contains the bulk of the AppArmor profiles

## Identify the Component of a Linux Distro that a file belongs to

### rpm / yum (CentOS/RHEL)

`rpm -qlp <rpmName>` will return a list of files associated with an rpm package

`rpm -qf <pathToFile>` will return the package name that provides that file
- `yum whatprovides <pathToFile>` does the same thing but with yum instead

### dpkg / apt (Debian/Ubuntu)

`dpkg -L <packageName>` will return a list of files associated with a deb package

`dpkg -S <pathToFile>` will return the name of the package that provides the file

## Create, Delete, and Modify Local User Accounts

`useradd <userName>` is the legacy command to add users
- This is guaranteed to be around in all Linux distributions
- `-d <absolutePath>` will specify a directory to add with the user
- Will require `passwd <userName>` to set a password for the user
- `chown` the home dir to the newly created user

`adduser` is a command in more modern distributions that adds the manual
steps above into the command itself

`userdel <userName>` deletes a local user
- Does *not* remove the home directory or any directories owned by the user
- `-r` will clean up the home directory if required

## Create, Delete, and Modify local groups and group memberships

`addgroup` will create a new group

`groupadd` will also create a new group

To add a user to a group, add the user name to the end of last colon on the
desired group in `/etc/group` file

For instance:

```plaintext
test1:x:1002:nselpa
```

Comma separate users if multple members need to exist:

```plaintext
test2:x:1003:nselpa,nicks
```

`groups` command will tell you the group membership of the user you're logged
in under

`newgrp <groupname>` will allow for joining the group membership also
- Any new files created will become owned by the last group assigned to the user
  - This is reset back to the user's home group for subsequent logins

`gpasswd <groupName>` will allow for setting a password to join the local group

## Manage system-wide environment profiles

`env` will show all the current environment variables
- `-i bash` is a way to launch a new shell with no environment variables and
  may be helpful for troubleshooting

`export VARNAME="Contents of variable"` is an example of how to set an
environment variable for the current session

`unset VARNAME` will remove the environment variable from the current session
- `export VARNAME=""` will have a similar effect as `unset`

`~/.bashrc` is a file that will set environment variables for non-login
shells (aka local shells and not virtual terminals [vty])

`~/.bash_profile` and `~/.profile` are another location to set local user
environment variables

`/etc/environment` will configure system-wide environment variables

`/etc/profile` is another location to specify system-wide variables

`/etc/profile.d/` is a folder that will has its contents executed for remote
sessions that are initiated

## Manage Template User Environment

This is to manage the template `/etc/skel/` for new user's home directory
- Any changes after the fact ***will not be reflected*** in previously
  provisioned users

## Configure User Resource Limits

`/etc/security/limits.conf` is the file that needs to be edited to manage
resource limits
- It has a `man` page
- The file has a format of: `<domain>` `<type>` `<item>` `<value>`
- The file has rich documentation within itself
- Soft and hard limits can be set on the same item
  - Soft limits are more suggestions and can be modified by a normal user
  - Hard limits are strictly enforced and cannot be ignored by a normal user

## Manage User Privileges

`/etc/security/access.conf` is used to enforce whether a user can log into a
system
- The file, like `limits.conf` has good documentation within itself

`id` command will echo back the current user's:
- User ID (uid)
- Group ID (gid)
- Group Memberships (groups)

## Configure PAM

Section largely talks about its function and how it needs to be incorporated into
the application for use.

`/etc/pam.conf` can be used to manage access modules, **however**:
- If ***any*** files live in `/etc/pam.d/` directory, `/etc/pam.conf` is
  completely ignored

## Configure networking and hostname resolution statically or dynamically

### Older Debian Systems

`/etc/network`
- `interfaces` file
- `interfaces.d/` directory
  - Should have `.cfg` files for the device
    - Usually prefixed with the device name.  i.e.: `eth0.cfg`

In a device configuration file, this is what a static address config would look
like:
```plaintext
auto eth0
iface eth0 inet static
address 10.9.8.7
netmask 255.255.255.0
gateway 10.9.8.1
dns-search mydomain.com
dns-nameservers 8.8.8.8 8.8.4.4
```

To apply the changes, run `sudo ifup <deviceId>`

`iface <deviceId> inet dhcp` will use the DHCP client of the server to receive
address information from a DHCP server

### Newer Debian Systems

`/etc/network`
- `interfaces` file
- `interfaces.d/` directory
  - Should have `.cfg` files for the device
    - Files in here are not device specific but instead a collection of
      configuration files that it executes top-down based on file order in
      the directory

### CentOS / RHEL

`/etc/sysconfig/network-scripts/`
- `ifcfg-<deviceName>` are the files that contain the network device configuration

Device configuration file, while in pricinple can read to infer how the
device is configured, is a completely different syntax.  Here's a DHCP config:

```plaintext
BOOTPROTO=dhcp
DEVICE=eth0
HWADDR=0a:67:42:8d:24:9e
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
```

Here's a static address configuration:

```plaintext
BOOTPROTO=none
DEVICE=eth0
HWADDR=0a:67:42:8d:24:9e
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.9.8.7
PREFIX=24
GATEWAY=10.9.8.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

`systemctl restart network` will apply network changes

## Configure Network Services to Start Automatically at Boot

### SystemD

`sudo systemctl` will show all running services

`sudo systemctl status xinetd` to show the service status
- Use `start` if it is not started on the system

Check `/etc/services` file to ensure the service is configured to the right port

`sudo systemctl enable <serviceName>` will enable the service on boot

### SysV

`chkconfig` will show all the services and their runlevel
- You can `grep` for the service in the list to see what the config is

`chkconfig <service> on` will turn the service on at boot

`sudo service xinetd start` to start the service

## Implement Packet Filtering

Leverages `iptables` to do this.

`iptables -L` lists all the current policies

`iptables --flush` will remove all policies and rules on a system

`iptables -P <chainName> [ACCEPT/DROP/REJECT]` will configure the default
policy for the specified chain
- Chains out of the box include `INPUT`, `FORWARD`, and `OUTPUT`

`iptables -A INPUT --protocol icmp --in-interface eth0 -j REJECT`
- `-A` is [A]dd a rule to the `INPUT` chain
- `--protocol` specified the protocol to match on
- `--in-interface <devId>` is the inbound interface the traffic is received on
- `-j` [j]umps to the action to take which in this rule is `REJECT`

## Start, Stop, and check the status of network services

This section focuses on `netstat`

// TODO: Look at `Statically Route IP Traffic` and
`Synchronize Time Using Other Network Peers` videos at a later time

## Configure a Caching DNS Server

Focused on configuring BIND

Section covers CentOS

`yum install bind bind-utils` to get BIND and DNS utilities installed on the
server

The file `/etc/named.conf` is the DNS server config file location on a CentOS/
RHEL system.  Here are some of the options of importance:

- `listen-on port [portNumber] { [ipv4Address] }` to specify which port and
  what IPv4 addresses to listen for DNS queries
  - `listen-on-v6` is the IPv6 equivalent
- `allow-query` specifies where DNS queries are permitted to come from
  - This defaults to `localhost`; Add `any` to the config if you want this to
    be a caching server (or specify the networks/hosts permitted)
- `allow-query-cache { localhost; any; };` allows any query to be cached locally

The file `/etc/named.conf` should be owned by `root` and bound to group `named`

The SELinux context (if SELinux is enabled) should be:

```plaintext
system_u:object_r:named_conf_t:s0 named.conf
```

If that's incorrect, then the following command will fix it:

```plaintext
semanage fcontext -a -t named conf t /etc/named.conf
```

The same thing needs to be specified for the `named.rfc1912.zones` file:

```plaintext
system_u:object_r:named_conf_t:s0 named.rfc1912.zones
```

Use the `named-checkconf /etc/named.conf` command to ensure the DNS config is
correct.  If it's correct, then the service can be restarted and enabled:

```plaintext
systemctl restart named
systemctl enable named
```

Remember to open port 53 on the OS firewall if that is traffic is nor permitted
by the current host configuration

## Maintain a DNS Zone

Checking the contents of `/etc/named/named.conf` the `directory` parameter
specified in the `options` block is where the zone files and folders live.

The syntax for a new master zone is:

```bind
zone "myzone.horse" in {
    type master;
    file "myzone.horse.zone";
}
```

The zone file is then read and loaded on service restart.

Some useful variables that can be used in a zone file:

- `$INCLUDE` - allows configuration import from other files
- `$ORIGIN` - appends the FQDN to unqualified records
- `$TTL` - Time a resource record can be valid before it needs to be refreshed
  - Measured in seconds

Here's a sample collection of records in the zone file:

```bind
$ORIGIN la.local
$TTL 600

@   IN  SOA dns1.la.local.  mai101.la.local (
    1;      // Serial
    21600;  // Time to Refresh
    3600;   // Retry Interval
    604800; // Time to Expiry
    86400;  // Minimum Time to Live 
)


webserver   IN  A   10.9.8.7
mail01    IN  A   10.9.8.150
dns1    IN  A   10.9.8.5
dns2    IN  A   10.9.8.6

www IN  CNAME   webserver

    IN  MX  10  mail01.la.local
    IN  MX  20  mail02.ca.local

    IN  NS  dns1.la.local
    IN  NS  dns2.la.local
```

## Connect to Network Shares

### Server Side

On a CentOS/RHEL system, get the file share utilities ready for NFS by:

`yum install nfs-utils`

When creating the share folder, specifying `nfsnobody:nfsnobody` for the share
location can stave off of NFS read and write issues.

The following services need to be enabled:
- rpcbind
- nfs-server
- nfs-idmap

Check the status of those services using the normal service commands in Linux.

NFS share definitions live in the `/etc/exports` file.

Here's a sample share entry:

```nfs
/share 172.31.96.178(rw,sync,no_root_squash,no_all_squash)
```

That format is:

```plaintext
[absolutePathToShare] [network(s)ToShareWith](shareOptions)
```

When in doubt, reference the `man` pages for the share options details.

The NFS services needs to be restarted when any changes are made to the config.

### Client Side

Create a mount point to attach the network share to.  Use the following command:

`mount -t nfs 172.31.124.130:/share /mnt/remote`

## Configure email aliases

Focuses on postfix

The configuration for postfix lives in `/etc/postfix/`

Create a file called `aliases` in the above directory.

As an example, to alias `webmaster` to the user `user` on a system, enter:

```plaintext
webmaster: user
```

To go to multiple users, create a comma separated list:

```plaintext
chad: chad, boss
```

To refresh the aliases added to postfix, run `postalias <pathToAliasesFile>`

```plaintext
sudo postalias /etc/postfix/aliases
```

## Configure SSH Servers and Clients

### Client Configuration

Lives in `~/.ssh` for a user's configuration

### Server Configuration

Lives in `/etc/ssh/sshd_config`

### "Password-less" SSH Login

- Create a private key with `ssh-keygen`
- Copy public key to target server into `authorized_keys`.  You may use the
  built-in command `ssh-copy-id` to accomplish this
  - This will require a password for the target system

## Restrict Access to HTTP Proxy Servers

Prerequisite:  Install Squid (HTTP Proxy Server) Application

Configuration lives in `/etc/squid/squid.conf`

First, create an acl grouping.  Here's some sample syntax:

```squid
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.1.0/24
```

Then, you'll make a rule for `http_access` and use an `allow` verb to consume
the `localnet` acl:

```squid
http_access allow localnet
```

## Configure an IMAP and IMAPS Service (and POP3 and POP3S)

Find the group ID for `postfix` in `/etc/group` using:

```plaintext
cat /etc/group | grep postfix
```

You can also check which group is being used by `ls`ing `/var/mail` as well.
This is a prerequisite for dovecot

`sudo yum install dovecot` for CentOS/RHEL and `sudo apt install dovecot-core`
for Debian/Ubuntu

The configuration lives in `/etc/dovecot/`

Edit the `10-mail.conf` file.  The configuration file has a considerable amount
of documentation within itself.

To install POP3 and IMAP for dovecot, install the `dovecot-pop3d` and 
`dovecot-imapd` packages with the appropriate installation system based on
distro.

Those create config files in `/etc/dovecot/conf.d/` for IMAP and POP3

In `/usr/share/dovecot/`, there is a script called `mkcert.sh` which will make
self-signed certificates to use for IMAPS and POP3S.

The SSL configuration in Dovecot lives in `10-ssl.conf` in
`/etc/dovecot/conf.d/`.  You may need to uncomment lines in the configuration
file and ensure that the config file is pointing to the correct certificate
file.

Restart the `dovecot` service.  To ensure the service is running, check
the processes and grep for `dovecot`.  Also, grep for the posts that Dovecot is
listening on using `netstat -tulpn` (may require a sudo)

## Configure an HTTP Server

### RHEL/CentOS

**NOTE**: Assume you need `root` to run all commands

`yum install httpd` to install Apache 2

You can use `lynx` to verify that the web server has been installed correctly
locally on the server.  Lynx is a text-based browser

Enable the service with `systemctl enable httpd`

Start the service with `systemctl enable httpd`

The configuration files for Apache live in `/etc/httpd/`.  The folders in there
are as follows:
- `conf` - Global configuration files; Less likely to need to be configured
- `conf.d` - These configuration files supersede `conf`; Is where all the site
  configuration lives
- `conf.modules.d` - Modules configuration
- `logs` (symlinked): Log files for Apache
- `modules` (symlinked): HTTP modules for Apache
- `run` (symlinked): PID file

The `IncludeOptional` directive inside of `/etc/httpd/conf/httpd.conf` is what
enabled the `conf.d` folder to have additional config impact on the system.

If you want the configuration to be more discrete for virtual host
configuration, then you can add another line of config to `httpd.conf`:

```apache
IncludeOptional vhosts.d/*.conf
```

The `vhosts.d` directory needs to exist.

### Debian/Ubuntu

This will focus on the differences from RHEL/CentOS

The package name is `apache2`

The service is up and running after the installation with an auto-configuration.

The configuration files live in `/etc/apache2/`.  The base config file is
`apache2.conf`.  It also has a different collection of folders:
- `conf-available`
- `conf-enabled`
- `mods-available`
- `mods-enabled`
- `sites-available`
- `sites-enabled`

This comes with a command that allows for enabling and disabling of items using
a commands called:
- `a2enmod` / `a2dismod` - enables and disables mods
- `a2ensite` / `a2dissite` - enables and disables sites
- `a2enconf` / `a2disconf` - enables and disables configurations

`apache2ctl` is another way of controlling Apache2 as well as
`/etc/init.d/apache2`

## Configure HTTP Server Log Files

In RedHat/CentOS, you can edit log settings in `/etc/httpd/conf/httpd.conf`

This is looking to configure the access logs (error logs are immutable) with
the `LogFormat` directive.  The syntax is:

```apache
LogFormat <differentFormat markers> <LogFormatName>
```

A sample of this would be (from the default config):

```apache
LogFormat "%h %l %u %t \"%r\" %>s %b" common
```

## Restrict Access to a Web Page

In the default config at `/etc/httpd/conf/httpd.conf` you'll need to configure
the following:

In the `<Directory>` blocks:
- The syntax is: `<Directory [absPathToFolder]>`
  - `Order allow,deny` will configure the directory enforcement to allow
    or whitelist addresses and networks and then implicitly block everything
    else

Here's a same block:

```apache
<Directory /var/www/html/test/>
  Order allow,deny
  Allow from 52.206.180.246
  Allow from 172.31.34.52
  Allow from 127.0.0.1
</Directory>
```

## Configure a Database Server

***NOTE***: It is assumed all the commands are going to be run as `root`

For MariaDB, use the `mariadb-server` and `mariadb-client` packages
- They're both the same for CentOS and Ubuntu

You can then do an initial hardening of the installation with
`mysql_secure_installation` command.

The main gotcha around MariaDB is checking the service status, it still operates
under the alias of `mysql`

## Manage and Configure Containers

I took this material on Pluralsight but will just make a crib sheet based on
what is covered in this video.

`docker ps` lists running containers

```docker
docker run -dit --name linuxacademy-testweb -p <hostPort>:<containerPort> -v
/home/chad/webstuff/:/usr/local/apache2/htdocs/ httpd:latest
```

That creates a detached instance with the name `linuxacademy-testweb` that will
listen on the host port and will forward the app from the container's port.  A
volume of `/home/chad/webstuff/` will be redirected to
`/usr/local/apache2/htdocs/` using the latest `httpd` container image

`docker stop <containerName>` will stop a container

`docker start <containerName>` will resume a container

`docker rm <containerName>` will remove that container instance

`docker image ls` will list all downloaded docker images

`docker image rm <dockerImageName:version>` will delete a specific image

## Manage and Configure Virtual Machines

***NOTE***: It is assumed all the commands are going to be run as `root`

`yum install qemu-kvm libvirt libvirt-client virt-install virt-viewer` would
be the command to run on CentOS/RHEL to install the appropriate virtualization
packages.

`cat /proc/cpuinfo | grep vmx` is used to check for virtualization extensions
on Intel processors

`cat /proc/cpuinfo | grep svm` is used to check for virtualization extensions
on AMD processors

`virt-install --name=tinyalpine --vpus=1 --memory=1024 --cdrom=<pathToIso>`
` --disk size=5` will make a VM named `tinyalpine` with 1 vCPU and 1GB of RAM 
(1024 MB) and will mount an ISO to the virtual machine.

The `virsh` tool is a shell tool to manage the virtual environments

`virsh list --all` will list all running VMs

`virsh edit <vmName>` will open the VI editor to change VM settings within the
XML file

`virsh autostart <vmName>` will configure a VM to auto-start on host boot
- `--disable` flag will remove auto-start from a VM

`virt-clone --original=tinyalpine --name=tiny2 --file=/var/lib/libvirt/images/`
`tinyalpine2.qcow2` will clone `tinyalpine` to `tiny2`
- The VM should be paused or off to permit this operation

## List, Create, Delete and Modify physical storage partitions

`lsblk` will list all block devices attached
- This will show what, if any, partitions and mount points for those partitions
  are on a system

`fdisk` will show more detailed information about a block device's partition
configuration

`gparted` (graphical version) or `parted` (command line version) will also
allow for parition management in Linux

## Manage and Configure LVM Storage

Ensure that `lvm2` has been installed on the system using `yum` or `apt`

Using `fdisk` the partition type should be `8e` (Linux LVM)
- Select `l` option in `fdisk` to list the partition types to confirm

### Partition Volume Create

`pvcreate [listOfPartitionsSeparatedBySpaces]` will prepare the partitions for
use with LVM

### Volume Group Create

`vgcreate [volumeName] [listOfPartitionsSeparatedBySpaces]` will create the new
volume group with the specified partition devices

### Logical Volume Create

`lvcreate --name <lvname> --size <sizeOfVolume> <volumeGroupName>` will create
the logical volume.

### Logical Volume Display

`lvdisplay` will show detailed information on the logical volumes configured on
a system

Ensure you pick a filesystem that can be expanded later on.  EXT4 is an
appropriate candidate

```bash
mkfs -t ext4 /dev/<vgName>/<lvName>
```

The `vgName` and `lvName` portion is assuming the expected behavior of LVM is to
create the device with that convention

### List commands

`pvs` lists LVM partitions

`vgs` lists LVM volume groups

`lvs` lists LVM volume groups

### Expanding an LVM volume

It would use the following process:
- `fdisk` to extend a volume (if required and not an explicit device was added)
- `pvcreate` on the new partition
- `vgextend <lvmGroupName> <lvmPartition>` will add the partition to the LVM
  group
- `e2fsck -f <device>` to check the LVM device that is about to be extended
- `resize2fs <device>` to extend the EXT partition to match the new partition
  size

## Create and Configure Encrypted Storage

`grep -i config_dm_crypt /boot/config-$(uname -r)` ill check to see if the
encryption module has been compiled for the installed kernel.

`lsmod | grep dm_crypt` will check to see if the module is actively loaded

`yum install cryptsetup` will install the necessary administrative tools to
create an encrypted disk

`cryptsetup -y luksFormat <partitionDevicePath>` will start the encryption
process.  Follow the screen prompts.

`cryptsetup` with no options will show all the command arguments that can be
set

`cryptsetup luksOpen <partitionDevicePath> <name>` will decrypt the partition
after giving the passphrase.  `lsblk` will show the unlocked partition using the
`<name>` label specified above
- This partition lives in `/etc/mapper/` for use

TODO: LOOK UP WHAT `/etc/mapper` FUNCTIONS AS

Then you'll need to `mkfs` and lay a filesystem on top of the encrypted
partition

Mount the file system as you would any the volume

`cryptsetup luksClose <name>` will seal the partition
- The device should be unmounted before sealing the partition

## Configure Systems to Mount File Systems at or During Boot

`/etc/fstab` lesson

`sudo blkid` will show the UUIDs of all block devices attached to the system

The format inside of `fstab` is

1. UUID of storage device or device ID
2. Mount point
3. Filesystem type
4. Mount options for the device
- `defaults` is a common option to set for mount options
5. Dump bit
6. `fsck` disk check order
- root file system would get `1`
- all other disks would likely get `2`
  - This can be modified if you have a specific order of checking the disk
- `0` or `no value` will skip the disk check

## Configure and Manage Swap Space

***NOTE***: Assume all commands have `root` privileges

`swapoff -a` disables all swap on the running system

`swapon -a` enables all swap on the running system

To make a swap file:
- `dd` a file with `/dev/zero` device
  - Make sure to specify the size if required
- Run `mkswap <swapFilePath>` to prepare the swap file for use
- `swapon <swapFilePath>` to enable the swap file

The **required** permissions for a swap file are `600`

`/etc/fstab` will show where the swap disk lives

## Create and Manage RAID devices

***NOTE***: Assume all commands have `root` privileges

Using `fdisk`, set the disk type to `fd` for `Linux raid auto`
- If you forget the code, just list the types while running fdisk on the 
  selected disk

Install multi-disk admin `mdadm` using the package manager of choice

Sample command to make a RAID

```bash
mdadm --create --verbose <multiDiskId> --level=stripe --raid-devices=2
<explicitDeviceNamesSpaceSeparated>
```

`cat /proc/mdstat` will show the status of multi-disk devices configured on the
system

`mdadm --detail <multiDiskId>` will return the information for a specific RAID
device

Lay down a filesystem to use the newly created RAID device like you would any
other disk

To make the installation more permanent and durable, you'll need to configure
the following files.

- On Debian/Ubuntu: `/etc/mdadm/mdadm.conf`
- On CentOS/RHEL: `/etc/mdadm.conf`

`mdadm --detail --scan` will return device information for RAID devices in a
format to copy/paste into the above config file

After adding to the conf file, run `mdadm --assemble --scan`

(For Ubuntu?) `update-rc.d mdadm defaults`
(For CentOS) `systemctl enable mdmonitor`

In `/etc/default/mdadm`, edit the file and add: `AUTOSTART=true`

## Configure Systems to Mount Filesystems on Demand

`yum install samba-client samba-common cifs-utils` to install the SAMBA packages

`smbclient -U <username> -L <sharePath>` on a local network

`smbclient -I <ipAddress> -U <username> -L <sharePath>` to explicitly define
a remote target to query

Create a `.smbcredentials` file with the following contents:

```samba
username=<user>
password=<password>
```

`chmod` the `.smbcredentials` file to `600`

Add the share to `/etc/fstab`

```fstab
//192.168.100.100/shareName [mountPoint] cifs credentials=[pathTo.smbcredentials],defaults 0 0
```

After everything is configured, run `mount -a` which will connect all the
missing mount points in `/etc/fstab` to the system

## Create, Manage, and Diagnose Advanced File System Permissions

Section on the 'sticky bit' (another set of 0 - 7 in the first position out of
four)

When `chmod`ing a file or folder, you add an additional number in front of the
`###` permissions like so:

```plaintext
sudo chmod 1770 targetdir
```

That will create an `ls` entry like:

`drwxrwx--T  2 root lxd  4096 Apr   5 15:58 adv-perm`

The sticky bit with a `1` prevents users from deleting files they are not the
owner of in a directory

If it's a `2` then it's the `setguid` to be a specified group owner, using the
directory group configuration as its assumed value for `setguid`.  Using the
`adv-perm` directory as an example:

`sudo chmod 2770 adv-perm/`'

It results in an `ls` like the following:

`drwxrws---  2 root lxd  4096 Apr   5 15:58 adv-perm`

To configure both the sticky bit plus the `setguid` bit, use a `3`:

`sudo chmod 3770 adv-perm/`

You can find files with the sticky bit set using the `find` command with the
following arguments passed to it:

- All directories w sticky bit set: `sudo find / -type d -perm -2000`

You can configure a file with a bit that will execute a command with the file
owner's permissions instead of the user executing it using:

`sudo chmod 4755 binaryfile`

## Setup User and Group Disk Quotas for File Systems

***NOTE***: It is assumed the commands typed below are executed as `root`

Install the `quota` package using the package manager of choice

Inside of `/etc/fstab`, you add the option `usrquota` to a mount's options

Remount with `mount -o remount /` if applied to the root folder

Here are the options for `quotacheck`:

```plaintext
Utility for checking and repairing quota files.
quotacheck [-gucbfinvdmMR] [-F <quota-format>] filesystem|-a

-u, --user                check user files
-g, --group               check group files
-c, --create-files        create new quota files
-b, --backup              create backups of old quota files
-f, --force               force check even if quotas are enabled
-i, --interactive         interactive mode
-n, --use-first-dquot     use the first copy of duplicated structure
-v, --verbose             print more information
-d, --debug               print even more messages
-m, --no-remount          do not remount filesystem read-only
-M, --try-remount         try remounting filesystem read-only,
                          continue even if it fails
-R, --exclude-root        exclude root when checking all filesystems
-F, --format=formatname   check quota files of specific format
-a, --all                 check all filesystems
-h, --help                display this message and exit
-V, --version             display version information and exit
```

`edquota <username>` will configure the quotas for a particular user

`repquota -a` will show all usage from all users on the system relative to their
quotas

`edquota -t` will edit the grace period for a soft quota violation
- This is a system wide configuration and not something that can be managed per
  user

## Create and Configure File Systems

`mkfs` lesson

```plaintext
Usage:
 mkfs [options] [-t <type>] [fs-options] <device> [<size>]

Options:
 -t, --type=<type>  filesystem type; when unspecified, ext2 is used
     fs-options     parameters for the real filesystem builder
     <device>       path to the device to be used
     <size>         number of blocks to be used on the device
 -V, --verbose      explain what is being done;
                      specifying -V more than once will cause a dry-run
 -V, --version      display version information and exit;
                      -V as --version must be the only option
 -h, --help         display this help text and exit

For more information see mkfs(8).
```

After the fileysystem is created, you `mount` the filesystem you would any other
way

