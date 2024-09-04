#!/bin/bash

filename="helloworld.txt"

# Start an infinite loop
while true; do
    # Check if the file exists
    if [ ! -f "$filename" ]; then
        # If the file does not exist, create it with some content
        echo "helloworld" > "$filename"
    fi

    # Display the contents of the file, but discard the output
    cat "$filename" > /dev/null

    # Wait for 10 seconds before repeating - enough time to run the capture
    sleep 10
done
