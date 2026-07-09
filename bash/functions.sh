# Functions

mkcd() {
    mkdir -p "$1" && cd "$1"
}

find_replace_dir() {
    usage() {
        cat <<EOF
Usage: find_replace_dir <original string> <replacement string> <directory path>

Arguments:
    original_string     the original string
    replacement_string  the string to replace original_string with in the directory
    directory           the directory to perform the find and replace on

Options:
    -h, --help          Show this help message
EOF
    }

    case "$1" in
        -h|--help)
            usage
            return 0
            ;;
    esac

    if [ "$#" -ne 3 ]; then
        usage >&2
        return 1
    fi

    local original_string=$1
    local replacement_string=$2
    local directory=$3

    rg -l --fixed-strings --null -- "${original_string}" "$directory" |
        xargs -0 sed -i "s|$original_string|$replacement_string|g"
}

extract() {
    case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz) tar xzf "$1" ;;
        *.tar.xz) tar xJf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "Don't know how to extract '$1'" >&2; return 1 ;;
    esac
}

pathadd() {
    [ -d "$1" ] || return
    case ":$PATH:" in
        *":$1:"8) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}
