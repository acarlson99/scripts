# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Disable compfix
ZSH_DISABLE_COMPFIX="true"

# Path to your oh-my-zsh installation.
export ZSH="/nfs/2018/a/acarlson/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  colored-man-pages
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

launchctl remove com.apple.suggestd
launchctl remove com.apple.followupd
find ~/Library/Logs/DiagnosticReports -mindepth 1 -delete > /dev/null 2>&1

rm -f ~/.zcompdump*

alias mysql='/usr/local/mysql/bin/mysql'

# Brew

mkdir -p /tmp/.$(whoami)-brew-locks
export PATH="$HOME/.brew/bin:$PATH"
export PATH="$HOME/.valgrind/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"
alias brew_check='brew leaves | xargs brew deps --installed --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"'

alias rubynette="$HOME/.rubynette/rubynette.rb"
alias 42FileChecker="bash ~/.42FileChecker/42FileChecker.sh"

alias sublime="/Volumes/Mac\ OS/Applications/Sublime\ Text.app/Contents/MacOS/Sublime\ Text"
alias subl='sublime'
alias atom="/Volumes/Mac\ OS/Applications/Atom.app/Contents/MacOs/Atom"
alias vscode="/Volumes/Mac\ OS/Applications/Visual\ Studio\ Code.app/Contents/MacOs/Electron"

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
alias ec="emacsclient -c"
alias vim='emacsclient -c'
alias vi='emacsclient -c'

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
