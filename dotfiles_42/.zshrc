unfunction precmd

launchctl remove com.apple.suggestd
launchctl remove com.apple.followupd
find ~/Library/Logs/DiagnosticReports -mindepth 1 -delete > /dev/null 2>&1

mkdir -p /tmp/.$(whoami)-brew-locks
alias make-brew-work=mkdir -p /tmp/.$(whoami)-brew-locks

# rm -f ~/.zcompdump*
# rm -rf ~/Library/*.42_cache_bak* 2>/dev/null >/dev/null

alias mysql='/usr/local/mysql/bin/mysql'

# source ~/.profile

alias brew_check='brew leaves | xargs brew deps --installed --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"'

alias rubynette="$HOME/.rubynette/rubynette.rb"
alias 42FileChecker="bash ~/.42FileChecker/42FileChecker.sh"

alias sublime="/Volumes/Mac\ OS/Applications/Sublime\ Text.app/Contents/MacOS/Sublime\ Text"
alias subl='sublime'
alias atom="/Volumes/Mac\ OS/Applications/Atom.app/Contents/MacOs/Atom"
alias vscode="/Volumes/Mac\ OS/Applications/Visual\ Studio\ Code.app/Contents/MacOs/Electron"

alias csi='rlwrap csi'

GRN='\033[0;32m'
RED='\033[0;31m'
PNK='\033[35m'
NC='\033[0m'

PS1_DEFAULT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'
PS1_NBR='%(?..[%?] )%# '

MY_LIBFT='https://github.com/bombblob/libft.git'
MY_GITIGNORE='https://github.com/bombblob/gitignore_template.git'

alias cat='~/.brew/bin/bat'
alias ft_gcc="gcc -Wall -Wextra -Werror"
alias ft_cpp="clang++ -std=c++98 -Wall -Wextra -Werror"
alias grep='egrep  --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'

alias giturl='git config --get remote.origin.url'

# alias p3='python3'

alias p3='~/anaconda3/bin/python3.7'
alias pip='~/anaconda3/bin/pip'

# Helpful functions

make_author() {
	if [ $# -gt 0 ] && [ $1 = '-h' ]
	then
		echo "creates author file named 'author' and fills it with \$USER"
		return 0
	fi
	echo $USER > author
}

todo_check() {
	if [ $# -eq 0 ]
	then
		egrep -R "(?:TODO|FIXME)" ./
	elif [ $1 = '-h' ]
	then
		echo 'usage: todo_check [files]'
		echo '\tuses grep to check for TODO or FIXME messages'
		echo '\tgreps recursively if no arguments are given.  Otherwise only checks only files/dirs supplied as argument'
	else
		egrep -R "(?:TODO|FIXME)" $@
	fi
}

init_dir() {
	if [ $# -gt 0 ] && [ $1 = '-h' ]
	then
		echo 'usage: init_dir repo_link'
		echo '\tcalls git init and pushes everything to supplied repo'
		return 0
	elif [ -d .git ]
	then
		echo ".git folder already exists"
	elif [ $# -eq 0 ]
	then
		echo "No argument provided"
	else
		git init
		echo "git init"
		git add .
		echo "git add ."
		git commit -m "First commit"
		echo 'git commit -m "First commit"'
		git remote add origin $1
		echo "git remote add origin $1"
		git push -u origin master
		echo "git push -u origin master"		
	fi
}

clone_libft() {
	echo "cloning libft"
	git clone ${MY_LIBFT} libft/ && rm -rf libft/.git libft/.gitignore
}

clone_gitignore() {
	echo "cloning .gitignore template"
	git clone ${MY_GITIGNORE} gitignore_dir && cp gitignore_dir/.gitignore ./ && rm -rf gitignore_dir/
}

start_project() {
	if [ $# -gt 0 ] && [ $1 = '-h' ]
	then
		echo 'usage: start_project [git_repo_link]'
		echo '\tclones libft and gitignore template and makes author file'
		echo '\tcalls init_dir if git link is supplied'
		return 0
	elif [ -d libft/ ]
	then
		echo "libft/ is already a directory"
	else
		clone_libft
		clone_gitignore
		echo "making author file"
		make_author
		if [ $# -ne 0 ]
		then
			echo "calling git init on $1"
			init_dir $1
		fi
	fi
}

kill_process () {
	if [ $# -gt 0 ] &&  [ $1 = '-h' ]
	then
		echo 'usage: kill_process process_name'
		echo '\tfor use when you run valgrind with fsan'
		return 0
	elif [ $# -eq 1 ]
	then
		kill -9 $(ps -a | grep '['$(echo $1 | sed 's/\(.\{1\}\)/\1]/') | awk '{print $1}')
	else
		echo "Invalid number of arguments"
	fi
}

make_tags() {
	case $1 in
		c)
			find . -type f -iname "*.[ch]" | etags -
			;;
		cpp)
			find . -type f -iname "*.[cht]pp" | etags -
			;;
		python)
			find . -type f -iname "*.py" | etags -
			;;
		go)
			find . -type f -iname "*.go" | etags -
			;;
		elisp)
			find . -type f -iname "*.el" | etags -
			;;
		*)
			echo "usage: make_tags language"
			echo '\tcurrently supported: c cpp python go elisp'
			;;
	esac
}

norm_range() {
	if [ $# -ne 3 ] || [ $1 = '-h' ]
	then
		echo 'usage: norm_range file start_line end_line'
		return 0
	fi
	norminette $1 | egrep '^[EW]' | awk -F'[\(\) ,]' "(\$4 >= $2 && \$4 <= $3)"
}

normc() {
	if [ $# -gt 0 ] && [ $1 = '-h' ]
	then
		echo 'usage: normc [files]'
		echo '\truns norm and trims output to two lines'
	fi
	norm=$(norminette $@)
	num_warn=$(echo $norm | egrep -c "^W" &)
	num_errs=$(echo $norm | egrep -c "^E" &)
	wait
	if [ ${num_warn} -eq 0 ]
	then
		echo -e "${GRN}Boy howdy Billy ya did it!  No warnings!   :)${NC}"
	else
		echo -e "${PNK}Oh no... ${num_warn} warning(s)...${NC}"
	fi
	if [ ${num_errs} -eq 0 ]
	then
		echo -e "${GRN}Boy howdy Billy ya did it!  No errors!  :)${NC}"
	else
		echo -e "${RED}Oh no... ${num_errs} error(s)...${NC}"
	fi
}

emacs_server() {
	case $1 in
		run)
			if [ $(pgrep 'emacs') ]
			then
				echo 'Emacs server already running'
			else
				emacs --bg-daemon
			fi
			;;
		kill)	# THIS IS DANGEROUS!!! THIS WILL LOSE YOUR WORK
			if [ $(pgrep 'emacs') ]
			then
				emacsclient -e '(kill-emacs)'
			else
				echo 'No emacs server running'
			fi
			;;
		*)
			echo "usage: emacs_server (run|kill)"
			echo "use kill with caution.  It is better to kill the server from within emacs"
			;;
	esac
}

alias e='emacs'
alias ds="emacs_server run"
alias ec="emacsclient -c --alternate-editor vi"
alias vim='emacsclient -c --alternate-editor vi'
alias vi='emacsclient -c --alternate-editor vi'

make_() {
	if [ $# -eq 1 ] && [[ $1 -eq 're' ]]
	then
		echo "Making l, you silly boy"
		/usr/bin/make l
	else
		/usr/bin/make $@
	fi
}

touch_php() {
	touch $@;
	echo "#! /usr/bin/php
<?php

?>" >> $@;
	chmod 744 $@;
}

alias update-go='go get github.com/rogpeppe/godef && go get -u github.com/mdempsky/gocode && go get -u github.com/sqs/goreturns && go get -u golang.org/x/tools/... && go get -u github.com/go-delve/delve/cmd/dlv'
