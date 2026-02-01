# Rust/Cargo (only if installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Locale (only if available)
if locale -a | grep -q "en_US.UTF-8"; then
    export LC_ALL="en_US.UTF-8"
    export LANG="en_US.UTF-8"
fi
