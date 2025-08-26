#!/usr/bin/env bash
#Usage with rust: measure_mem.sh --json <filename>.json -- cargo r -r --bin <binary>

set -euo pipefail

# Configurable number of runs
NUM_RUNS=${NUM_RUNS:-10}
total_bytes=0

# Detect OS and set measurement parameters
OS_TYPE="$(uname)"
if [[ "$OS_TYPE" == "Darwin" ]]; then
  TIME_CMD="/usr/bin/time -l"
  MEM_LABEL="maximum resident set size"
  MEM_POS=1
  # According to macOS man-page, this value is already in bytes :contentReference[oaicite:0]{index=0}
  MEM_UNIT_MULTIPLIER=1
elif [[ "$OS_TYPE" == "Linux" ]]; then
  TIME_CMD="/usr/bin/time -v"
  MEM_LABEL="Maximum resident set size"
  MEM_POS=6
  # GNU time reports ru_maxrss in kilobytes (KB) :contentReference[oaicite:1]{index=1}
  MEM_UNIT_MULTIPLIER=1024
else
  echo "Unsupported OS: $OS_TYPE"
  exit 1
fi


# Default JSON output filename
json_file="memory_report.json"

# Parse options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--json)
      if [[ $# -lt 2 ]]; then
        echo "Error: $1 requires a filename" >&2
        exit 1
      fi
      json_file="$2"
      shift 2
      ;;
    --) shift; break ;;        # end of options
    -h|--help)
      echo "Usage: $0 [-o output.json] -- <command> [args...]"
      exit 0
      ;;
    *)
      break  # first non-option argument
      ;;
  esac
done

# Ensure there is a command to run
if (( $# == 0 )); then
  echo "Error: No command specified." >&2
  echo "Usage: $0 [-o output.json] -- <command> [args...]" >&2
  exit 1
fi

echo "Running command: $* (averaging over $NUM_RUNS runs)"
echo "JSON output file: $json_file"

for i in $(seq 1 $NUM_RUNS); do
  echo " Run #$i..."
  
  # Run the command and capture both program output and measurement output
  output=$({ $TIME_CMD "$@" 2>&1 >/dev/null; } 2>&1)

  # Locate the memory measurement line
  line=$(echo "$output" | awk -v lab="$MEM_LABEL" 'tolower($0) ~ tolower(lab) {print $0}')

  if [[ -z "$line" ]]; then
    echo "  Error: Could not locate memory info in output."
    exit 1
  fi

  # Extract the numeric value (last token)
  raw=$(echo "$line" | awk -v pos="$MEM_POS" '{print $pos}')

  if ! [[ "$raw" =~ ^[0-9]+$ ]]; then
    echo "  Error: Numeric memory value not found (got '$raw')"
    exit 1
  fi

  # Convert to bytes
  bytes=$(( raw * MEM_UNIT_MULTIPLIER ))
  echo "  Peak memory: ${bytes} bytes"

  total_bytes=$(( $total_bytes + $bytes ))
done

# Compute average
avg_bytes=$(( total_bytes / NUM_RUNS ))
avg_mib=$(awk "BEGIN { printf \"%.2f\", ${avg_bytes}/1024/1024 }")

echo
echo "Average peak memory across $NUM_RUNS runs:"
echo "  • ${avg_bytes} Bytes"
echo "  • ${avg_mib} MiB"


# Prepare JSON output
json_output=$(jq -n \
  --argjson runs "$NUM_RUNS" \
  --argjson avg_bytes "$avg_bytes" \
  '{runs: $runs, average_bytes: $avg_bytes}'
)

echo "$json_output" > "$json_file"
echo "Result saved to $json_file"
jq . "$json_file"