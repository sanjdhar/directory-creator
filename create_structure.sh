#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input-file>"
    exit 1
fi

input_file=$1

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found"
    exit 1
fi

# Initialize variables
current_path="."
declare -a path_stack=(".")

# Read the input file line by line
while IFS= read -r line; do
    # Count the number of leading box-drawing characters to determine depth
    indent=$(echo "$line" | grep -o '^[└├─┬┴│ ]*' | wc -c)
    indent=$((indent - 1))
    
    # Clean the line by removing box-drawing characters and trimming
    clean_line=$(echo "$line" | sed -e 's/[└├┘─┬┴│]//g' -e 's/^ *//' -e 's/ *$//')
    
    # Skip empty lines
    if [ -z "$clean_line" ]; then
        continue
    fi
    
    # Calculate depth level (each level is 4 spaces in the tree)
    level=$((indent / 4))
    
    # Adjust path stack based on level
    while [ ${#path_stack[@]} -gt $((level + 1)) ]; do
        unset 'path_stack[${#path_stack[@]}-1]'
    done
    
    # Get current path by joining stack elements
    current_path=$(IFS=/; echo "${path_stack[*]}")
    
    # Determine if this is a directory (ends with /)
    if [[ "$clean_line" == */ ]]; then
        # It's a directory
        dir_name=$(echo "$clean_line" | sed 's/\/$//')
        mkdir -p "$current_path/$dir_name"
        echo "Created directory: $current_path/$dir_name"
        path_stack+=("$dir_name")
    else
        # It's a file
        touch "$current_path/$clean_line"
        echo "Created file: $current_path/$clean_line"
    fi
done < "$input_file"

echo "Folder structure and files created successfully in current directory."