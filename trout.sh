#!/bin/zsh

# variables
DB_PATH="$HOME/Library/Group Containers/9K33E3U3T4.net.shinyfrog.bear/Application Data/database.sqlite"
API_URL="http://localhost:3000/trout/notes/inventory"

# fetch all notes in Bear.app's local sqlite3 db
GET_BEAR_NOTES_MODIFIED_TIMESTAMPS="
    SELECT
        Z_PK AS ID,
        ZMODIFICATIONDATE
    FROM
        ZSFNOTE;"

# present the result of the notes modified fetch to the api
IDS_TO_SYNC=$(sqlite3 -json "$DB_PATH" "$GET_BEAR_NOTES_MODIFIED_TIMESTAMPS" | curl -X POST "$API_URL" -H "Content-Type: application/json" --data-binary @-)
