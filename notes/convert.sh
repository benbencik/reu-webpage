#!/bin/bash

# get input file
input_file=$1

# cut .md to get the base name
base_name=$(echo $input_file | cut -d '.' -f 1)

# Format title by replacing hyphens with spaces and capitalizing words
title=$(echo $base_name | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

# Get current date in the desired format
current_date=$(LC_TIME=en_US.UTF-8 date +"%B %d, %Y")
file_date=$(date +"%Y-%m-%d")

# Create a temporary file for processing
temp_file="${base_name}_temp.md"

# Remove spacing around math delimiters and add title to metadata
(
    echo "---"
    echo "title: '$title'"
    echo "date: '$current_date'"
    echo "---"
    sed -E '
        s/\$[[:space:]]*([^$[:space:]].*?[^$[:space:]])[[:space:]]*\$/\$\1\$/g;
        s/^\$\$(.+)\$\$$/\$\$\n\1\n\$\$/g;
    ' "$input_file"
    
) > "$temp_file"        

# Run pandoc with the date variable
pandoc "$temp_file" -f markdown -t html -s --mathjax --template=template.html > "${base_name}_temp.html"

sed -zE "
    # Def callout
    s@<blockquote>\s*<p>\[!definition\]\s*@<blockquote class="definition"><p>@g;
    
    # Theorem callout
    s@<blockquote>\s*<p>\[!theorem\]\s*@<blockquote class="theorem"><p>@g;
    
    # Lemma callout
    s@<blockquote>\s*<p>\[!lemma\]\s*@<blockquote class="lemma"><p>@g;
    
    # Note callout
    s@<blockquote>\s*<p>\[!note\]\s*@<blockquote class="note"><p>@g;
" "${base_name}_temp.html" > "${file_date}-${base_name}.html"

# Clean up temporary file
rm "$temp_file" "${base_name}_temp.html"