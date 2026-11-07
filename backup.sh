#!/bin/bash
#
# backup.sh - create timestamped backups of a folder
# Usage: backup.sh [-d DEST] [-k KEEP] [-v] SOURCE
# Author: Ama Nkeng, Rebase Code Camp
#
# ---- settings ---------------------------------------------------
DEST="$HOME/backups"
KEEP=5
VERBOSE=false
# ---- helper functions -------------------------------------------
usage() {
cat <<EOF
Usage: $(basename "$0") [-d DEST] [-k KEEP] [-v] SOURCE
Options:
-d DEST
-k KEEP
-v
-h
EOF
}
#where to store backups (default: "$DEST")
#how many backups to keep (default: "$KEEP")
#verbose output
#show this help
die() {
echo "Error: $*" >&2
exit 2
}
# $* is all the arguments joined into one string
log() {
if [[ "$VERBOSE" == true ]]; then
echo "[$(date +%H:%M:%S)] $*"
fi
}

create_backup() {
    local source=$1
    local dest=$2

    local timestamp
    timestamp=$( date +%Y%m%d-%H%M%S )
    local folder_name
    folder_name=$(basename "$source")

    local archive_name=${folder_name}-${timestamp}.tar.gz
    local dest_path="$dest/$archive_name"

    #checking destination
    mkdir -p "$dest"

    log "creating backup for '$source'"

    #archive using -C for clean paths
    tar -czf "$dest_path" -C "$(dirname "$source")" "$folder_name" || { echo "Error: could not create archive" >&2; exit 1; }

    if tar -tzf "$dest_path" > /dev/null; then
        echo "Successfully created and verified: $archive_name"
        rotate_backups "$source" "$dest" "$KEEP"
    else
        echo "Error: archive verification failed" >&2
    fi 
         }

rotate_backups () {
    local source=$1
    local dest=$2
    local keep=$3

    local folder_name
    folder_name=$(basename "$source")
    log "rotating backups, keeping newest $keep"

    #list backup newest first , skip the first KEEP, delete the rest
    # shellcheck disable=SC2012
    ls -1t "$dest"/"$folder_name"-*.tar.gz 2>/dev/null | tail -n +$((keep+1)) | while IFS= read -r old; do
        log "removing old backup: $(basename "$old")"
        rm -- "$old"
    done
}


# ---- main logic -------------------------------------------------
main() {
# ...parse options, validate, do the work...
: # ':' is a command that does nothing; it keeps the empty function valid

    while getopts ":d:k:vh" opt; do
        case "$opt" in
            d) DEST="$OPTARG" ;;
            k) KEEP="$OPTARG" ;;
            v) VERBOSE=true ;;
            h) usage; exit 0 ;;
            :) die "option -$OPTARG needs a value" ;;
            \?) die "unknown option -$OPTARG" ;;
        esac
    done
    shift $((OPTIND - 1))
    # remove the options; what's left are the arguments
    SOURCE="$1"

#validation decision
#checking if slice has source
if [[ -z "$SOURCE" ]] ; then 
    die "missing directory"
fi

if [[ ! -d "$SOURCE" ]] ; then
    die "$SOURCE isn't a directory"
fi

if ! [[ "$KEEP" =~ ^[1-9][0-9]*$ ]]; then
    die "keep must be a positive interger"
fi

echo "SOURCE: '$SOURCE'"
echo "DEST: '$DEST'"
echo "KEEP: '$KEEP'"

create "$SOURCE" "$DEST"

}



main "$@"

