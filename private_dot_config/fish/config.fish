
# # Set up fzf key bindings
if status is-interactive
    # Commands to run in interactive sessions can go here
    fzf --fish | source
end
atuin init fish | source

fish_vi_key_bindings
set fish_greeting ""
set -gx EDITOR nvim

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

if set -q TMUX
    and test -n "$WAYLAND_DISPLAY"
    tmux set-environment -g WAYLAND_DISPLAY "$WAYLAND_DISPLAY"
    tmux set-environment -g DISPLAY "$DISPLAY"
    tmux set-environment -g XDG_SESSION_TYPE "$XDG_SESSION_TYPE"
end

# Function to generate Pokemon sprite
function generate_pokemon_sprite
    # Generate random number between 1 and 20
    set random_num (random 1 75)
    
    # Default command without shiny
    set base_command "pokemon-colorscripts -r 1-6 --no-title"
    
    # If random number is 1 (5% chance), add shiny flag
    if test $random_num -eq 1
        set base_command "$base_command --shiny"
    end
    
    # Execute command and save output to sprite file
    eval $base_command > $HOME/.config/fish/pokemonsprite
end

# Function to display fastfetch with Pokemon sprite
function display_fastfetch
    fastfetch --logo $HOME/.config/fish/pokemonsprite
end

# Generate new sprite and display fastfetch
function pokemon_display
    generate_pokemon_sprite
    display_fastfetch
end

alias ls lsd
alias lg lazygit
alias n nvim
alias bright "ddcutil setvcp 10 100 --display 1 && ddcutil setvcp 10 100 --display 2"
alias dim "ddcutil setvcp 10 0 --display 1 && ddcutil setvcp 10 0 --display 2"

zoxide init fish | source

set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk
set -x ANDROID_HOME /home/luuk/Android/Sdk
pyenv init - fish | source

if set -q TMUX
    
else
   pokemon_display
end

starship init fish | source
