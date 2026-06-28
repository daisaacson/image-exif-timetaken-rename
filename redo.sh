#!/usr/bin/env bash

f=$(find . -name "*Day Care.jpg")

# build groups (safe: preserves spaces, avoids leading newline)
declare -A bydate
while IFS= read -r file; do
  [[ $file =~ ([0-9]{8}) ]] || continue
  d=${BASH_REMATCH[1]}
  if [[ -z "${bydate[$d]}" ]]; then
    bydate[$d]="$file"
  else
    bydate[$d]+=$'\n'"$file"
  fi
done <<< "$f"

# iterate dates sorted; unique files per-date and sort filenames
while IFS= read -r d; do
  echo "Date: $d"
  printf '%s\n' "${bydate[$d]}" | sed '/^$/d' | sort -u | while IFS= read -r file; do
    echo "  -> $file"
    # process "$file"
  done
done < <(printf '%s\n' "${!bydate[@]}" | sort)
