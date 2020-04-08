# ef theme, based on mh theme
# mh preview: http://cl.ly/1y2x0W0E3t2C0F29043z

# features:
#  path is autoshortened to ~30 characters
#  displays git status (if applicable in current folder)
#  displays current virtualenv (if activated)
#  displays current knife block in use (if available)
#    will only search up to ${ZSH_THEME_FIND_UPWARDS_MAX:-3} directories above current
#    requires `miscutils` installed: `cargo install --git https://glow.dev.maio.me/seanj/miscutils.git`
#  turns username red if superuser, otherwise it is blue

export VIRTUAL_ENV_DISABLE_PROMPT=1

ZSH_THEME_FIND_UPWARDS_MAX=${ZSH_THEME_FIND_UPWARDS_MAX:-5}

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="("
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=")"

ZSH_THEME_SSH_PROMPT_PREFIX="["
ZSH_THEME_SSH_PROMPT_SUFFIX="%f]"
ZSH_THEME_SSH_PROMPT_TITLE="%F{red}SSH: %F{gray}"

ZSH_THEME_KNIFE_BLOCK_PREFIX="["
ZSH_THEME_KNIFE_BLOCK_SUFFIX="%f]"
ZSH_THEME_KNIFE_BLOCK_TITLE="🔪%F{blue}:"

ZSH_THEME_ENVMGR_BLOCK_PREFIX="["
ZSH_THEME_ENVMGR_BLOCK_SUFFIX="%f]"
ZSH_THEME_ENVMGR_BLOCK_TITLE="🌲%F{green}:"

function __readlink() {
    local path="${1}"
    [[ -z "${path}" ]] && return 1;
    [[ ! -e "${path}" ]] && return 127;
    [[ ! -L "${path}" ]] && echo "${path}" && return 0;
    echo ${path}(:A)
}

function knife_block_prompt_info() {
    if [ ! $commands[mu] ] ; then
        return
    fi

    # `mu find-upwards` will canonicalize all paths before returning them, meaning
    # we will not need to deal with resolving paths.
    local chef_dir=$(mu find-upwards --max-depth="${ZSH_THEME_FIND_UPWARDS_MAX}" ".chef")
    if [ ! -z "${chef_dir}" ] ; then
        local current_block="${chef_dir}/knife.rb"
        if [ -e "${current_block}" ] ; then
            # `current_block` will be something like: /Path/to/.chef/knife-environment.rb
            local current_block=$(__readlink "${current_block}")
            local current_block=$(basename "${current_block}")
            current_block=${current_block#knife-}
            current_block=${current_block%.rb}
            echo "${ZSH_THEME_KNIFE_BLOCK_PREFIX}${ZSH_THEME_KNIFE_BLOCK_TITLE}${current_block}${ZSH_THEME_KNIFE_BLOCK_SUFFIX}"
        fi
    fi
}

function envmgr_prompt_info() {
    if [ ! $commands[envmgr] ] ; then
        return
    fi

    if [ -n "$ENVMGR_NAME" ] ; then
        echo "$ZSH_THEME_ENVMGR_BLOCK_PREFIX$ZSH_THEME_ENVMGR_BLOCK_TITLE$ENVMGR_NAME$ZSH_THEME_ENVMGR_BLOCK_SUFFIX"
    fi

function virtualenv_prompt_info() {
    if [ -n "$VIRTUAL_ENV" ] ; then
        if [ -f "$VIRTUAL_ENV/__name__" ] ; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ]; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX$name$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
    fi
}

function ssh_prompt_info() {
    if [ -n "$SSH_CONNECTION" ]; then
        local shortname=$(hostname --short)
        echo "${ZSH_THEME_SSH_PROMPT_PREFIX}${ZSH_THEME_SSH_PROMPT_TITLE} ${shortname}${ZSH_THEME_SSH_PROMPT_SUFFIX}"
    fi
}

# if superuser make the username blue
if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="cyan"; fi

# prompt
EDGE_CHAR="%F{039}λ%f"
PROMPT='$(ssh_prompt_info)$(envmgr_prompt_info)[%{$fg[$NCOLOR]%}%n%{$reset_color%}:%{$fg[magenta]%}%30<...<%~%<<%{$reset_color%}]$(knife_block_prompt_info)%(!.#. $EDGE_CHAR) '
RPROMPT='$(git_prompt_info)$(virtualenv_prompt_info)'

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%F{gray}( \u21cc %f%B%F{158}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b%F{gray} )%f "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red} ✱ %f"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%F{gray}( \u267b  %f%B%F{159}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%f%b%F{gray} )%f "

