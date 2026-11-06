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
exit 1
}
# $* is all the arguments joined into one string
log() {
if [[ "$VERBOSE" == true ]]; then
echo "[$(date +%H:%M:%S)] $*"
fi
}

#create() {
    #local source=$1
    #local dest=$2

    #local timestamp
    #timestamp=$( date +%Y%M%D-%H%M%S )
    #local folder_name
    #folder_name=$(basename "$source"

    #local archive_name=${folder_name}-${timestamp}.tar.gz
    #local dest_path="$dest/$archive_name"

    #checking destination
    #mkdir -p "$dest"

    #log creating backup for "source"

    #archive using -C for clean paths
    #tar -czf "dest_path" -C "$(dirname "$src")" "$folder_name" || die "could not create archive"

    #if tar -tzf "$target_path" > /dev/null; then
        #log "Successfully created and verified: $archive_name"
    #else
        #die "archive verification failed"
    #fi 
#}



# ---- main logic -------------------------------------------------
main() {
# ...parse options, validate, do the work...
: # ':' is a command that does nothing; it keeps the empty function valid

    local dest="$DEST"
    local keep="$KEEP"
    local source=""

    while getopts ":d:k:vh" opt; do
        case "$opt" in
            d) dest="$OPTARG" ;;
            k) keep="$OPTARG" ;;
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

if ! [[ "$KEEP" =~ ^[0-9]+$ ]] || ((keep <= 0)); then
    die "keep must be a positive interger"
fi

echo "SOURCE: '$source'"
echo "DEST: '$dest'"
echo "KEEP: '$keep'"

create_backup "$source" "$dest"
}



main "$@"

