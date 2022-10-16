# fedora setup
```sh
## if twitch not working
## install rpmfusion https://rpmfusion.org/
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y ffmpeg ffmpeg-devel
## coreutils
dnf install git coreutils emacs the_silver_searcher
```

# brightness
```
xrandr -q | grep '\bconnected\b' | head -n 1 | cut -d ' ' -f1
xrandr --output eDP-1 --brightness 0.4
```

# sound
```
alsamixer
amixer -c 0 set PCM 5%+
```

# restart xfce
```
xfce4-panel -r
xfwm4 --replace

xfce4-settings-editor

xfconf-query -c xfce4-panel -p / -R -r
xfce4-panel -r
```

# emacs
```
systemctl --user start emacs
emacsclient -c file
```

# git
```
git clone ssh://git@github.com/acarlson99/repo.git
```

# inotify file limit
```
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl -p		# apply changes (I think)
```

# mount partition
```
udisksctl mount -b /dev/sda3
```

# add key to ssh
```
ssh-add ~/.ssh/id_keyname
```

# screen record
```
peek
```

# dnf
```
https://tylersguides.com/guides/listing-files-in-a-package-with-dnf/

dnf repoquery -l pulseaudio-libs-devel # list files in repo
rpm -ql crontabs
```

# enable setrlimit systemctl

```
If you believe that systemctl should be allowed setrlimit access on processes labeled NetworkManager_t by default.
You should report this as a bug.
You can generate a local policy module to allow this access.
Allow this access for now by executing:
# ausearch -c 'systemctl' --raw | audit2allow -M my-systemctl
# semodule -X 300 -i my-systemctl.pp
```

# IP

```sh
curl https://ifconfig.me/all
curl ipinfo.io
```

# find IP

```sh
curl ifconfig.me
curl ifconfig.me/all
```

# edit application menu
```
~/.local/share/applications

https://wiki.xfce.org/howto/customize-menu
```

# datetimectl
```
timedatectl set-local-rtc 0
timedatectl set-timezone America/Los_Angeles
```
