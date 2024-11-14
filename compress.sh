#!/bin/bash
# source: https://www.linuxfordevices.com/tutorials/linux/creating-zip-bombs
# idea: https://github.com/iamtraction/ZOD

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

# Define a base directory for all tiers
base_dir="compression_layers"
mkdir -p "$base_dir"

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
    # Create a separate directory for each tier inside the base directory
    dir_name="$base_dir/tier_$i"
    mkdir -p "$dir_name"
    
    # Determine the number of characters to strip based on the tier number
    if (( i < 10 )); then
        remove_chars=3
    else
        remove_chars=4
    fi

    # Strip the specified number of characters from the end of the filename (basename only)
    base_name="${input_file%.*}"
    stripped_name="${base_name:0:${#base_name}-$remove_chars}"

    # Construct the new filename for the current layer inside the new directory
    layer_file="$dir_name/${stripped_name}_v${i}.7z"

    # Compress the file and rename accordingly
    7zz a -t7z "$layer_file" "$input_file" >/dev/null
    echo "Tier $i compression complete: $layer_file"

    # Remove the previous file and replace with the new compressed file
#    rm -f "$input_file"
    input_file="$layer_file"
done

echo "Layered compression from tier $tier_from to tier $tier_to completed."
