# ef theme, based on mh theme
# mh preview: http://cl.ly/1y2x0W0E3t2C0F29043z

# features:
#  path is autoshortened to ~30 characters
#  displays git status (if applicable in current folder)
#  displays current virtualenv (if activated)
#  turns username red if superuser, otherwise it is blue

export VIRTUAL_ENV_DISABLE_PROMPT=1

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="("
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=")"

ZSH_THEME_SSH_PROMPT_PREFIX="["
ZSH_THEME_SSH_PROMPT_SUFFIX="%f]|"
ZSH_THEME_SSH_PROMPT_TITLE="%F{red}SSH: %F{gray}"

function virtualenv_prompt_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then
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
PROMPT='$(ssh_prompt_info)[%{$fg[$NCOLOR]%}%n%{$reset_color%}:%{$fg[magenta]%}%30<...<%~%<<%{$reset_color%}]%(!.#. $EDGE_CHAR) '
RPROMPT='$(git_prompt_info)$(virtualenv_prompt_info)'

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%F{gray}( \u21cc %f%B%F{158}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b%F{gray} )%f "
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red} ✱ %f"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%F{gray}( \u267b  %f%B%F{159}"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%f%b%F{gray} )%f "

