#!/bin/bash

# Usage: ./websiteMonitor.sh <url_file>
# Example: ./websiteMonitor.sh urls.txt

TO="eb167@nyu.edu, mk5636@nyu.edu"
FROM="gencore@nyu.edu"
DOWN_URLS_FILE="/tmp/down_urls.txt"

if [ -z "$1" ]; then
  echo "Usage: $0 <url_file>"
  exit 1
fi

URL_FILE=$1

if [ ! -f "$URL_FILE" ]; then
  echo "File not found: $URL_FILE"
  exit 1
fi

# Function to check if a URL is in the down URLs file and if it should be skipped
should_skip_url() {
  local url=$1
  if [ -f "$DOWN_URLS_FILE" ]; then
    while read -r line; do
      down_url=$(echo $line | cut -d',' -f1)
      down_time=$(echo $line | cut -d',' -f2)
      current_time=$(date +%s)
      elapsed_time=$((current_time - down_time))
      if [ "$url" == "$down_url" ] && [ $elapsed_time -lt 3600 ]; then
        return 0
      fi
    done < "$DOWN_URLS_FILE"
  fi
  return 1
}

# Function to update the down URLs file
update_down_urls_file() {
  local url=$1
  local status=$2
  current_time=$(date +%s)
  if [ "$status" == "down" ]; then
    echo "$url,$current_time" >> "$DOWN_URLS_FILE"
  else
    grep -v "^$url," "$DOWN_URLS_FILE" > "${DOWN_URLS_FILE}.tmp" && mv "${DOWN_URLS_FILE}.tmp" "$DOWN_URLS_FILE"
  fi
}

while read -r URL; do
  if [ -n "$URL" ]; then
    if should_skip_url "$URL"; then
      echo "Skipping $URL (checked within the last hour)"
      continue
    fi

    # Check the URL 4 times once every 5 seconds before sending an email
    for i in {1..4}; do
      HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -L -k $URL)
      if [ "$HTTP_RESPONSE" -eq 200 ]; then
        break
      fi
      sleep 5
    done

    if [ "$HTTP_RESPONSE" -ne 200 ]; then
      SUBJECT="$URL DOWN"
      BODY="$URL is down - HTTPS Status: $HTTP_RESPONSE"
      EMAIL_CONTENT="To: $TO\nSubject: $SUBJECT\nFrom: $FROM\n\n$BODY"
      echo $BODY
      echo -e $EMAIL_CONTENT | /usr/sbin/sendmail -t
      update_down_urls_file "$URL" "down"
    else
      if should_skip_url "$URL"; then
        SUBJECT="$URL UP"
        BODY="$URL is back up - HTTPS Status: $HTTP_RESPONSE"
        EMAIL_CONTENT="To: $TO\nSubject: $SUBJECT\nFrom: $FROM\n\n$BODY"
        echo $BODY
        echo -e $EMAIL_CONTENT | /usr/sbin/sendmail -t
        update_down_urls_file "$URL" "up"
      fi
    fi
  fi
done < "$URL_FILE"
