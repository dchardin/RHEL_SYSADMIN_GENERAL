
# ==============================================================================
# Cryptsetup Exercise
#
# This is an exercise that I completed during my earlier days as a linux admin
# back in 2013. It was derrived from real life business requests serviced on a 
# regular basis. Tests skills concerning lvm, text 
# manipulation, storage encryption, and more.
#
# I intend to post a fresh copy without the solutions.
#
# I also intend to mine this file for potential automated scripts.
#
# ==============================================================================


# ==============================================================================
# Use 68% of the available free space in the vgsrv volume group to make
# a new logical volume called 'box'
# ==============================================================================


# --vgs shows vfree 384mb. We need to multiply .68 by 384

echo $((68 * 384))
26112


lvcreate -n /dev/vgsrv/box -L 261M

#BETTER WAY: 
lvcreate -n /dev/vgsrv/box -L %68FREE


# ==============================================================================
# Encrypt this logical volume via cryptsetup with LUKS formatting
# ==============================================================================

cryptsetup luksFormat box

info box



# ==============================================================================
a.) For the initial passphrase (for key-slot 0), use the word at line
number #217645 in the file called 'words'
# ==============================================================================

locate 'words'
vim +/217645 /usr/share//dict/words

#(The word is lasiocampoidea)

# ==============================================================================
b.) Add an additional passphrase (to key-slot 1) by using a word that
meets the following
1.) Search for words that have an 'f', an 'r', a 't', and an 'e',
in that order
2.) Narrow the results from #1 down to words that have a 'c' as
their 3rd character
3.) Narrow the results from #2 down to words thta end in 'r'
4.) If done correctly, this should lead to a single word
# ==============================================================================

grep f.*r.*t.*e `locate linux.words`
grep f.*r.*t.*e `locate linux.words` | grep ^..c
grep f.*r.*t.*e `locate linux.words` | grep ^..c | grep r$

#The word is microrefractometer


# ==============================================================================
Configure the logical volume to be automatically decrypted at boot-up
via a keyfile containing the second passphrase (key-slot 1)
# ==============================================================================

touch boxcode
echo -n microfractometer > boxcode

# notice i did not use vim or other text editor; you do not want to enter it in 
# manually. Endline characters / whitespaces, etc might throw the whole thing
# off


# ==============================================================================
# add the key for box by specifying the keyfile
# ==============================================================================


cryptsetup luksAddKey /dev/vgsrv/box /root/boxcode


# ==============================================================================
1.) Ensure that only root has access to read the keyfile
# ==============================================================================

chmod 000 boxcode


# ==============================================================================
2.) Ensure that the root user cannot delete the keyfile with rm
# ==============================================================================

chattr +i boxcode
fdisk -l /dev/vgsrv/box



# ==============================================================================
3.) In the end, also ensure that ...
- a luksDump on the logvol shows only two filled key-slots
- both passphrases can be used (interactively) to open the LV
* Put an ext4 filesystem on top of the newly-created and opened crypt device
# ==============================================================================

[root@server4 ~]# blkid /dev/mapper/boxen
[root@server4 ~]# mkfs -t ext4 /dev/mapper/boxen

# ==============================================================================
a.) Configure the filesystem to be mounted at /boxen
mkdir /dev/boxen
vim /etc/crypttab >>>> boxen /dev/vgsrv/box /root/boxcode
# ==============================================================================


# ==============================================================================
b.) Ensure the filesystem is NOT mounted up automatically
c.) Ensure that the filesystem can be automounted on-demand, but ensure
that a new user named 'sarah' (password: 'sarah') is the only one
that has any access to the filesystem
d.) Ensure that sarah has FULL access to create/modify files in /boxen,
including all future files
# ==============================================================================

setfacl -m d:u:sarah:rwx /boxen
vim etc/auto.master >>>> /- /etc/auto.box
vim etc/auto.box >>>>> /boxen -fstype=ext4 :/dev/mapper/boxen (,acl for temp acl mounting)
vim /etc/crypttab >>>> boxen /dev/vgsrv/box /root/boxcode



# ==============================================================================
* After the above, and after temporarily mounting the filesystem ... as root
run:
a.) `cryptsetup luksDump` against the crypt device, saving the output
to /boxen/luksDump
b.) `tune2fs -l` against the ext4 filesystem device, saving the output
to /boxen/tune2fs

##For whatever reason, I ended up creating another directory in boxen called
# "rootstuff" and placed the output capture files in there. Cant recall what
# I was thinking. 

# ==============================================================================

cd /boxen
mkdir rootstuff
cd rootstuff
touch luksDump
cryptsetup luksDump /dev/vgsrv/box > /boxen/rootstuff/luksDump
touch tune2fs
tune2fs -l /dev/mapper/boxen > /boxen/rootstuff/tune2fs


