#!/bin/bash
#########################
# Backups to DESTINATION_FOLDER / Zips and performs basic rotation
##########################

# Default source and destination folders
SOURCE_FOLDER="/var/www/html/"
DESTINATION_FOLDER="/var/www/backups/"
ROTATE_PERIOD=2  # Default rotation period in days

# Get the basename of the source folder
BASENAME=$(basename "$SOURCE_FOLDER")

# Get the current date in the format "dd-mm-yyyy"
datestamp=$(date +"%d-%m-%Y")

#### Display command usage ########
usage() {
    cat << EOF
USAGE:
    backuprot [OPTIONS] /source_folder/ /destination_folder/
    
Back up an entire folder, create a tgz archive, and perform x-day rotation of backups.
You must provide source and destination folders.

OPTIONS:
    -p Specify Rotation period in days - default is $ROTATE_PERIOD

EXAMPLES:
    backuprot -p 3 [/source_folder/] [/destination_folder/]
EOF
}

#### Getopts #####
while getopts ":p:" opt; do
    case "$opt" in
        p) ROTATE_PERIOD=${OPTARG};;
        \?) echo "Unknown option: -$OPTARG"
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

# Check if the user provided both source and destination folders
if [ -z "$1" ] || [ -z "$2" ]; then
    usage
    exit 1
else
    # Set source and destination folders based on user input
    SOURCE_FOLDER=$1
    DESTINATION_FOLDER=$2
    BASENAME=$(basename "$SOURCE_FOLDER")
    TGZFILE="$BASENAME-$datestamp.tgz"

    echo "Starting Backup and Rotate"
    echo "-----------------------------"
    echo "Source Folder : $SOURCE_FOLDER"
    echo "Target Folder : $DESTINATION_FOLDER"
    echo "Backup file   : $TGZFILE"
    echo "-----------------------------"

    # Check if source and destination folders exist
    if [ ! -d "$SOURCE_FOLDER" ] || [ ! -d "$DESTINATION_FOLDER" ]; then
        echo "SOURCE ($SOURCE_FOLDER) or DESTINATION ($DESTINATION_FOLDER) folder doesn't exist or is misspelled. Please check and try again."
        exit 1
    fi

    # Create the backup archive
    echo "Creating $TGZFILE ..."
    tar -zcvf "/tmp/$TGZFILE" -C "$SOURCE_FOLDER" .

    # Move the backup file to the destination folder
    echo "Moving $TGZFILE to $DESTINATION_FOLDER ..."
    mv "/tmp/$TGZFILE" "$DESTINATION_FOLDER"

    # Count the number of files in the destination folder
    FILE_COUNT=$(find "$DESTINATION_FOLDER" -maxdepth 1 -type f | wc -l)

    echo "Rotation period: $ROTATE_PERIOD days for $DESTINATION_FOLDER"
    echo "$FILE_COUNT files found in $DESTINATION_FOLDER folder"

    # Perform rotation if the file count exceeds the rotation period
    if [ "$FILE_COUNT" -gt "$ROTATE_PERIOD" ]; then
        echo "Removing backups older than $ROTATE_PERIOD days in $DESTINATION_FOLDER"
        find "$DESTINATION_FOLDER" -mtime +$ROTATE_PERIOD -exec rm {} \;
    else
        echo "Only $FILE_COUNT file(s), NOT removing older backups in $DESTINATION_FOLDER"
    fi
fi

echo "----------------"
echo "Backup_rot Complete."
echo "To extract the file, use: tar -xzvf $TGZFILE"
