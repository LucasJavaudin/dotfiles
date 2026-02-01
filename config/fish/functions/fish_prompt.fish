function fish_prompt
        if not set -q VIRTUAL_ENV_DISABLE_PROMPT
                set -g VIRTUAL_ENV_DISABLE_PROMPT true
        end

        # Check if inside a screen session
        if test -n "$STY"
            set -l screen_indicator "{screen}"
        else
            set -l screen_indicator ""
        end

        set_color yellow
        printf '%s' $USER
        set_color normal
        printf ' at '

        set_color magenta
        echo -n (prompt_hostname)
        set_color normal
        printf ' in '

        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)

        # Show screen status.
        if test -n "$STY"
            set_color red
            printf ' {%s} ' $STY
        end

        set_color normal

        # Display Git status if in a Git repository
        set -g __fish_git_prompt_showdirtystate true
        set -g __fish_git_prompt_showuntrackedfiles true
        set -g __fish_git_prompt_showcolorhints true
        printf '%s' (fish_git_prompt)

        # Line 2
        echo
        if test -n "$VIRTUAL_ENV"
                printf "(%s) " (set_color blue)(path basename $VIRTUAL_ENV)(set_color normal)
        end
        printf '↪ '
        set_color normal
end
