#!/bin/bash

curl -k -u "$NEXUS_LOGIN":"$NEXUS_PASSWORD" -X GET "$NEXUS_URL"/"$NEXUS_FILE" -o "$FILE_PATH"
