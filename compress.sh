#!/bin/bash

# Request user input for file, tier_from, and tier_to
read -p "Enter the file to compress: " input_file
read -p "Enter the starting tier (tier_from): " tier_from
read -p "Enter the ending tier (tier_to): " tier_to

# Ensure the input file exists
if [[ ! -f $input_file ]]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

# Check if the tiers are valid numbers
if ! [[ "$tier_from" =~ ^[0-9]+$ && "$tier_to" =~ ^[0-9]+$ && "$tier_from" -le "$tier_to" ]]; then
    echo "Error: Both 'tier_from' and 'tier_to' must be valid integers, with 'tier_from' <= 'tier_to'."
    exit 1
fi

# Start with tier 0 compression using bzip2 if tier_from is 0
if [[ $tier_from -eq 0 ]]; then
    bz2_file="${input_file%.*}.bz2"
    bzip2 -zk "$input_file" -c > "$bz2_file"
    echo "Tier 0 compression done: $bz2_file"
    input_file="$bz2_file"
    ((tier_from++))
fi

# Main compression loop from tier_from to tier_to using 7z, overwriting and renaming at each layer
for (( i=tier_from; i<=tier_to; i++ )); do
    # Determine the number of characters to strip based on the tier number
    if (( i < 10 )); then
        remove_chars=3
    else
        remove_chars=4
    fi
    
    # Strip the specified number of characters from the end of the filename (basename only)
    base_name="${input_file%.*}"
    stripped_name="${base_name:0:${#base_name}-$remove_chars}"
  
    # Construct the new filename for the current layer
    layer_file="${stripped_name}_v${i}.7z"
    
    # Compress the file and rename accordingly
    7zz a -t7z "$layer_file" "$input_file" >/dev/null
    echo "Tier $i compression complete: $layer_file"
    
    # Remove the previous file and replace with the new compressed file
#    rm -f "$input_file"
    input_file="$layer_file"
done

echo "Layered encryption from tier $tier_from to tier $tier_to completed."
