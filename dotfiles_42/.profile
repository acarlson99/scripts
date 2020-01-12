# PATH

export PATH="$HOME/.brew/bin:$PATH"
export PATH="$HOME/.valgrind/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

export PLAN9=/nfs/2018/a/acarlson/notapps/plan9port-master
export PATH=$PATH:$PLAN9/bin

export PATH="$HOME/important_bins:$PATH"

export GOPATH='/tmp/go/'

export PATH="${GOPATH}bin:$PATH"

# export PATH="$HOME/.rbenv/bin:$PATH"
# eval "$(rbenv init -)"

export CPLUS_INCLUDE_PATH="$HOME/.brew/include/"

alias vi=ed
alias vim=ed

export PGDATA=/tmp/postgres
export PS1='$ '

######################
# BEGIN SUDOLPHINING #
######################

define(){
    o=''
    while IFS="
" read -r a
    do o="${o}${a}"'
'
    done;
    eval "$1=\$o";
}

define dolphin_left <<'EOF'
                                                           __
                              .__                         / |
                             /  /                         |  \
                            /   |                     _-------'_
                       ____/     \_________      __--"      _/  \_
         _______------"                    "----"          _-\___/
     _--"                                               _-"
 ___<___                                          ___--"
(-------0                                   __---"
 `--___                                    /
       "--___\                _______-----"
             \\    (____-----"
              \\    \_
               `.`..__\
EOF

define dolphin_right <<'EOF'
                                                    ,adBBB8B88B8888b,
                            ,d8888ba,,,,,,,adBBBB8B888888888888888BB#,
                         d8888888888888888BBB8888888888888888(O;8B###RRR88b,
                            `VB888888888888888888888888888888888888PY8888P'
                              VWWB88888BB88B8B8888888888888888888P'
                             dWWBBBBBBBBB8BB8B888888888888888P'
                         ,dBBBBBBBBBBBBB8B88888888888888888P'
                      ,dBBBBBBBBBBBB888888888888P'  d8888P
                   ,dBBBBBBBBBBB8888888888P'     ,d8888P'
               ,adBBBBBBBBB888888888P'         d888P'
            ,dBBBBBBBBBB888888P'
         ,dBBBBBBBBBB888P'
;.aaad88bad8BBBBBBBBP'
 V88888888BBBP'
  Y888888P
  8888888
  I8888P
  888P
 88P
 V
EOF

sudo () {
    output=$(/usr/bin/env sudo $@)

    echo "${dolphin_left}" 1>&2
    echo "${output}"
    echo "${dolphin_right}" 1>&2
}

undolphin () {
    unset dolphin_left
    unset dolphin_right
    unset -f define;
    unset -f sudo;
    unset -f undolphin;
}

