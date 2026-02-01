if status is-interactive
    # Commands to run in interactive sessions can go here

    # Set SHELL to fish
    set -gx SHELL (which fish)

    # Increase history size
    set -g fish_history 10000

    # Make neovim the default editor
    set -x EDITOR "nvim"

    # Use vi mode
    fish_vi_key_bindings

    # Add .local/bin to paths
    fish_add_path ~/.local/bin
    # Add .local/bin to paths
    fish_add_path ~/.cargo/bin

    # === Aliases ===
    # Sudo neovim with usr config
    alias svim='sudo -E nvim'

    # Open pdf with zathura in new window
    alias zathura='zathura --fork'

    # Check for bat or batcat
    if type -q bat
        set bat_cmd bat
    else if type -q batcat
        set bat_cmd batcat
    end

    if test -n "$bat_cmd"
        alias cat="$bat_cmd -P"
        alias less="$bat_cmd"
        function fzf
            command fzf --preview "$bat_cmd --color=always --style=numbers --line-range=:500 {}"
        end
        function batdiff
            command git diff --name-only --relative --diff-filter=d -z $argv | xargs -0 $bat_cmd --diff
        end
        # Use bat to format help texts
        abbr -a --position anywhere -- --help '--help | $bat_cmd -plhelp'
        abbr -a --position anywhere -- -h '-h | $bat_cmd -plhelp'
        # Use bat for man pages
        set -x MANPAGER "$bat_cmd -plman"
        # set -x BAT_STYLE "changes,header-filename,header-filesize,snip,rule"
    end

    if type -q eza
        function ls
            command eza --color --group-directories-first $argv
        end
        function l
            command eza -lF --color --group-directories-first --no-permissions --no-user $argv
        end
        function la
            command eza -lhgAF --color --group-directories-first $argv
        end
    else
        function ls
            command ls --color --group-directories-first $argv
        end
        function l
            command ls -lhF --color --group-directories-first $argv
        end
        function la
            command ls -lhAF --color --group-directories-first $argv
        end
    end

    # Confirm before overwriting something
    abbr cp 'cp -i'
    abbr rsync 'rsync -Pa --progress'
    abbr ln 'ln -i'
    abbr mv 'mv -i'
    abbr rm 'rm -Iv'

    abbr df 'df -H'
    abbr du 'du -ch'

    abbr g git

    # Favorite directories
    set -x these "/home/ljavaudin/Nextcloud/Studies/these/"
    set -x research "/home/ljavaudin/Nextcloud/Research/"
    set -x metro "/home/ljavaudin/Nextcloud/Research/metropolis2/"

    # No greeting message.
    set -U fish_greeting

    function ex --description "Extract archives"
        if test -f "$argv[1]"
            switch (string lower (string replace -r '.*\.([^.]+)$' '$1' "$argv[1]"))
                case 'tar.bz2', 'tbz2'
                    tar xjf "$argv[1]"
                case 'tar.gz', 'tgz'
                    tar xzf "$argv[1]"
                case 'bz2'
                    bunzip2 "$argv[1]"
                case 'rar'
                    unrar x "$argv[1]"
                case 'gz'
                    gunzip "$argv[1]"
                case 'tar'
                    tar xf "$argv[1]"
                case 'zip'
                    unzip "$argv[1]"
                case 'Z'
                    uncompress "$argv[1]"
                case '7z'
                    7z x "$argv[1]"
                case 'zstd', 'zst'
                    zstd -d "$argv[1]"
                case '*'
                    echo "'$argv[1]' cannot be extracted via ex()"
            end
        else
            echo "'$argv[1]' is not a valid file"
        end
    end

    # Do not do anything when a command is not found.
    function fish_command_not_found
        __fish_default_command_not_found_handler $argv
    end

    # Run the last command.
    function last_history_item
        echo $history[1]
    end
    abbr -a !! --position anywhere --function last_history_item

    # Vi bindings for bépo
    # Default (command) mode
    # --- Movement with Count Support ---
    bind -M default c backward-char
    bind -M default r forward-char

    bind -M default s up-or-search
    bind -M default t down-or-search

    bind -M default 'é' forward-word
    bind -M default 'É' forward-bigword

    bind -M insert ctrl-n accept-autosuggestion
    bind -M insert ctrl-f accept-autosuggestion

    # Operators & Operator Mode
    # TODO: Not supported yet.
    # bind -M default l 'fish_vi_start_operator change'

    bind -M operator c 'fish_vi_exec_motion backward-char'
    bind -M operator r 'fish_vi_exec_motion forward-char'
    bind -M operator s 'fish_vi_exec_motion up-line'
    bind -M operator t 'fish_vi_exec_motion down-line'
    bind -M operator 'é' 'fish_vi_exec_motion forward-word-vi'
    bind -M operator 'É' 'fish_vi_exec_motion forward-bigword-vi'

    bind -M operator j 'fish_vi_exec_motion forward-jump-till'
    bind -M operator J 'fish_vi_exec_motion backward-jump-till'
    bind -M operator 'è' 'fish_vi_exec_motion repeat-jump'
    bind -M operator 'È' 'fish_vi_exec_motion repeat-jump-reverse'

    bind -M operator l 'fish_vi_exec_motion --linewise'

    bind 'd,è' begin-selection repeat-jump kill-selection end-selection
    bind 'd,È' begin-selection repeat-jump-reverse kill-selection end-selection

    bind -m insert k delete-char repaint-mode
    bind -m insert K kill-inner-line repaint-mode
    bind -m insert L kill-line repaint-mode
    bind -m insert l,\$ kill-line repaint-mode
    bind -m insert l,\^ backward-kill-line repaint-mode
    bind -m insert l,0 backward-kill-line repaint-mode

    bind -m insert l,i,w kill-inner-word repaint-mode
    bind -m insert l,i,W kill-inner-bigword repaint-mode
    bind -m insert l,a,w kill-a-word repaint-mode
    bind -m insert l,a,W kill-a-bigword repaint-mode
    bind -m insert l,i,b jump-till-matching-bracket and jump-till-matching-bracket and begin-selection jump-till-matching-bracket kill-selection end-selection
    bind -m insert l,a,b jump-to-matching-bracket and jump-to-matching-bracket and begin-selection jump-to-matching-bracket kill-selection end-selection
    bind -m insert l,i backward-jump-till and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode
    bind -m insert l,a backward-jump and repeat-jump-reverse and begin-selection repeat-jump kill-selection end-selection repaint-mode

    bind T end-of-line delete-char
    bind S 'man (commandline -t) 2>/dev/null; or echo -n \a'

    bind j forward-jump-till
    bind J backward-jump-till
    bind 'è' repeat-jump
    bind 'È' repeat-jump-reverse

    bind -m replace_one h repaint-mode

    bind -m replace H repaint-mode

    bind -M visual c backward-char
    bind -M visual r forward-char

    bind -M visual s up-line
    bind -M visual t down-line

    bind -M visual 'é' forward-word-vi
    bind -M visual 'É' forward-bigword-vi

    bind -M visual j forward-jump-till
    bind -M visual J backward-jump-till
    bind -M visual 'è' repeat-jump
    bind -M visual 'È' repeat-jump-reverse

    bind -M visual -m insert l kill-selection end-selection repaint-mode
    bind -M visual -m insert k kill-selection end-selection repaint-mode
    bind -M visual -m default u downcase-selection end-selection repaint-mode
    bind -M visual -m default U upcase-selection end-selection repaint-mode
end
