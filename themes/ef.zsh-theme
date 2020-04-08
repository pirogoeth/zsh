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

    local prefix="["
    local suffix="%f]"
    local title="🔪%F{blue}:"
    local find_upwards_max=${ZSH_THEME_FIND_UPWARDS_MAX:-5}

    # `mu find-upwards` will canonicalize all paths before returning them, meaning
    # we will not need to deal with resolving paths.
    local chef_dir=$(mu find-upwards --max-depth="${find_upwards_max}" ".chef")
    if [ ! -z "${chef_dir}" ] ; then
        local current_block="${chef_dir}/knife.rb"
        if [ -e "${current_block}" ] ; then
            # `current_block` will be something like: /Path/to/.chef/knife-environment.rb
            local current_block=$(__readlink "${current_block}")
            local current_block=$(basename "${current_block}")
            current_block=${current_block#knife-}
            current_block=${current_block%.rb}
            echo "${prefix}${title}${current_block}${suffix}"
        fi
    fi
}

function envmgr_prompt_info() {
    if [ ! $commands[envmgr] ] ; then
        return
    fi

    local prefix="["
    local suffix="%f]"
    local title="🌲%F{green}:"

    if [ -n "$ENVMGR_NAME" ] ; then
        echo "$prefix$title$ENVMGR_NAME$suffix"
    fi
}

function virtualenv_prompt_info() {
    local prefix="("
    local suffix=")"

    if [ -n "$VIRTUAL_ENV" ] ; then
        if [ -f "$VIRTUAL_ENV/__name__" ] ; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ] ; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "$prefix$name$suffix"
    fi
}

function ssh_prompt_info() {
    local prefix="["
    local suffix="%f]"
    local title="%F{red}SSH: %F{gray}"

    if [ -n "$SSH_CONNECTION" ] ; then
        local shortname=$(hostname --short)
        echo "${prefix}${title}${shortname}${suffix}"
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

