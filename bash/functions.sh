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

compress_dir() {
    local source_dir="${1:-}"
    local output_file="${2:-}"

    if [[ -z "$source_dir" || -z "$output_file" ]]; then
        printf 'Usage: compress_dir <directory> <output-file>\n' >&2
        printf 'Example: compress_dir ./project ./backups/project.tar.gz\n' >&2
        return 2
    fi

    if [[ ! -d "$source_dir" ]]; then
        printf 'Error: directory does not exist: %s\n' "$source_dir" >&2
        return 1
    fi

    # Resolve the source directory without requiring GNU realpath.
    local source_parent source_name output_abs
    source_parent="$(cd -- "$(dirname -- "$source_dir")" && pwd -P)" || return 1
    source_name="$(basename -- "$source_dir")"

    # Resolve the output path before changing directories.
    if [[ "$output_file" == /* ]]; then
        output_abs="$output_file"
    else
        output_abs="$PWD/$output_file"
    fi

    mkdir -p -- "$(dirname -- "$output_abs")" || return 1

    case "$output_file" in
        *.tar.gz|*.tgz)
            tar -C "$source_parent" -czf "$output_abs" "$source_name"
            ;;
        *.tar.bz2|*.tbz2)
            tar -C "$source_parent" -cjf "$output_abs" "$source_name"
            ;;
        *.tar.xz|*.txz)
            tar -C "$source_parent" -cJf "$output_abs" "$source_name"
            ;;
        *.tar.zst|*.tzst)
            tar -C "$source_parent" --zstd -cf "$output_abs" "$source_name"
            ;;
        *.tar)
            tar -C "$source_parent" -cf "$output_abs" "$source_name"
            ;;
        *.zip)
            command -v zip >/dev/null 2>&1 || {
                printf 'Error: zip is not installed.\n' >&2
                return 1
            }
            (
                cd -- "$source_parent" &&
                zip -rq "$output_abs" "$source_name"
            )
            ;;
        *.7z)
            command -v 7z >/dev/null 2>&1 || {
                printf 'Error: 7z is not installed.\n' >&2
                return 1
            }
            (
                cd -- "$source_parent" &&
                7z a "$output_abs" "$source_name"
            )
            ;;
        *)
            printf 'Error: unsupported output type: %s\n' "$output_file" >&2
            printf 'Supported: .zip, .tar, .tar.gz, .tgz, .tar.bz2, .tar.xz, .tar.zst, .7z\n' >&2
            return 2
            ;;
    esac

    local status=$?
    if (( status == 0 )); then
        printf 'Created: %s\n' "$output_abs"
    else
        printf 'Error: compression failed.\n' >&2
    fi

    return "$status"
}

speedtest() {
    curl -s https://raw.githubusercontent.com/PeterLinuxOSS/speedtest-cli/master/speedtest.py | python3 -
}

pathadd() {
    [ -d "$1" ] || return
    case ":$PATH:" in
        *":$1:"8) ;;
        *) export PATH="$1:$PATH" ;;
    esac
}

