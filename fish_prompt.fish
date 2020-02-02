# name: ocean
# A fish theme with ocean in mind.


## Set this options in your config.fish (if you want to)
# set -g theme_display_user yes
# set -g default_user default_username

set __oceanfish_shobon               '´･ω ･`'
set __oceanfish_shakin               '`･ω ･´'
set __oceanfish_glyph_radioactive    \u2622

set -x git_branch_glyph     \uE0A0
set -x git_dirty_glyph      '*'
set -x git_staged_glyph     '~'
set -x git_stash_glyph      \uf8ea


function _git_branch_name
    echo (command git symbolic-ref HEAD 2> /dev/null | awk '{
        sub(/refs\/heads\//, "")
        print
    }')
end

function _git_stashes
    echo (command git rev-list --walk-reflogs --count refs/stash)
end

function _is_git_staged
    echo (command git diff --cached --no-ext-diff 2> /dev/null)
end

function _is_git_dirty
    echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end


function fish_prompt
    set -l last_status $status

    set -l magenta      (set_color magenta)
    set -l red          (set_color de4343)
    set -l cyan         (set_color cyan)
    set -l white        (set_color white)
    set -l black        (set_color black)
    set -l bg_blue      (set_color -b blue)
    set -l bg_darkblue  (set_color -b 1a3a52)
    set -l bg_cyan      (set_color -b cyan)
    set -l bg_green     (set_color -b 58875a)
    set -l bg_white     (set_color -b white)
    set -l bg_red       (set_color -b de4343)
    set -l bg_orange    (set_color -b fb8d62)
    set -l bg_yellow    (set_color -b yellow)
    set -l normal       (set_color normal)

    set -l cwd $white(prompt_pwd)
    set -l uid (id -u $USER)


    # Show a yellow radioactive symbol for root privileges
    if [ $uid -eq 0 ]
        echo -n -s $bg_yellow $black " $__oceanfish_glyph_radioactive " $normal
    end


    # Display virtualenv name if in a virtualenv
    if set -q VIRTUAL_ENV
        echo -n -s $bg_cyan $black " " (basename "$VIRTUAL_ENV") " " $normal
    end


    # Show a nice shakin (turns shobon if previous command failed)
    if test $last_status -ne 0
        echo -n -s $bg_red $white " $__oceanfish_shobon "  $normal
    else
        echo -n -s $bg_blue $white " $__oceanfish_shakin " $normal
    end

    if [ "$theme_display_user" = "yes" ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            echo -n -s $bg_white $cyan " " (whoami) "@" (hostname -s) " " $normal
        end
    end

    # Display current path
    echo -n -s $bg_darkblue " $cwd " $normal


    # Show git branch and dirty state
    if [ (_git_branch_name) ]
        set -l branch_name (command echo (_git_branch_name) | awk '{
            sub(/^master$/, "")
            print
        }')

        if [ (_is_git_dirty) ]
            if [ (_is_git_staged) ]
                echo -n -s "$bg_orange $white $git_staged_glyph $branch_name"
            else
                echo -n -s "$bg_red $white $git_dirty_glyph $branch_name"
            end
        else
            echo -n -s "$bg_green $white $git_branch_glyph $branch_name"
        end

        set -l stash_count (_git_stashes)
        if [ "$stash_count" -ne 0 ]
            echo -n -s " $bg_yellow $white$git_stash_glyph $stash_count $normal"
        end
    end


    # Terminate with a space
    echo -n -s ' ' $normal
end
