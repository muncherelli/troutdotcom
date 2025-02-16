#!/usr/bin/env bash

# exit immediately if any command fails
set -e

# ensure the .env file exists before proceeding
if [ ! -f .env ]; then
  echo "Error: .env file does not exist."
  echo "Please create one from the example file. For example:"
  echo "  cp .env.example .env"
  exit 1
fi

# load environment variables from the .env file (ignoring commented lines)
set -a  # automatically export all variables
source .env || { echo "Error: failed to load .env file"; exit 1; }
set +a

# fail fast if TROUT_API_URI is not set
if [ -z "$TROUT_API_URI" ]; then
  echo "Error: TROUT_API_URI is not set in .env"
  exit 1
fi

# fail fast if TROUT_PUBLISH_KEY is not set
if [ -z "$TROUT_PUBLISH_KEY" ]; then
  echo "Error: TROUT_PUBLISH_KEY is not set in .env"
  exit 1
fi

# path to your Bear notes database
DB_PATH="$HOME/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"

# sqlite query to fetch the notes
GET_NOTES_MODIFIED="
    SELECT
        Z_PK AS ID,
        ZMODIFICATIONDATE
    FROM
        ZSFNOTE;
"

# the endpoint for posting
NOTES_MODIFIED_ENDPOINT="${TROUT_API_URI}/notes/modified"

# pipe the JSON from sqlite3 to curl, including the key header
IDS_TO_SYNC=$(
  sqlite3 -json "$DB_PATH" "$GET_NOTES_MODIFIED" |
  curl -X POST "$NOTES_MODIFIED_ENDPOINT" \
       -H "Content-Type: application/json" \
       -H "x-api-publish-key: $TROUT_PUBLISH_KEY" \
       --data-binary @-
)
