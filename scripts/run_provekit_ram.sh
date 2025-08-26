#!/usr/bin/env bash
# RAM benchmarking for ProveKit Noir R1CS using the CLI

set -euo pipefail

# Ensure we're in the project root (where ProveKit/ exists)
if [[ ! -d "ProveKit" ]]; then
  echo "Error: This script must be run from the project root (where ProveKit/ exists)" >&2
  exit 1
fi

# Config - all paths relative to project root
PROVEKIT_DIR="ProveKit"
CIRCUIT_POSEIDON_DIR="$PROVEKIT_DIR/noir-examples/poseidon-var"
CIRCUIT_KECCAK_PERM_DIR="$PROVEKIT_DIR/noir-examples/keccak-f-perm"
MEASURE_SCRIPT="scripts/measure_mem.sh"
RESULTS_DIR="scripts/ram_benchmark_results_provekit"
ROOT_DIR="$(pwd)"
MEASURE_SCRIPT_ABS="$ROOT_DIR/$MEASURE_SCRIPT"

# Defaults
POSEIDON_SIZES=(6 7 8 9)
KECCAK_SIZES=(5 6 7 8)

echo "Benchmarking ProveKit"
echo "  Poseidon-var sizes: ${POSEIDON_SIZES[*]}"
echo "  Keccak-f-perm sizes: ${KECCAK_SIZES[*]}"

if [[ ! -x "$MEASURE_SCRIPT" ]]; then
  echo "Error: measure_mem.sh not found or not executable at $MEASURE_SCRIPT" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR"

# Ensure noir-r1cs binary available (build once if missing)
if [[ ! -x "$PROVEKIT_DIR/target/release/noir-r1cs" ]]; then
  echo "Building noir-r1cs binary..."
  (cd "$PROVEKIT_DIR" && cargo build -q --release --bin noir-r1cs >/dev/null 2>&1)
fi

# Poseidon-var measurements
for log in "${POSEIDON_SIZES[@]}"; do
  echo "--- Poseidon-var LOG=$log ---"
  scheme_file="$CIRCUIT_POSEIDON_DIR/noir-proof-scheme_${log}.nps"
  inputs_file="$CIRCUIT_POSEIDON_DIR/Prover_${log}.toml"
  if [[ ! -f "$scheme_file" || ! -f "$inputs_file" ]]; then
    echo "Error: Missing scheme or inputs for LOG=$log: $scheme_file / $inputs_file" >&2
    exit 1
  fi

  out_file="$RESULTS_DIR/provekit_poseidon_var_log${log}.json"
  echo "Measuring proving RAM..."
  (
    cd "$CIRCUIT_POSEIDON_DIR"
    "$MEASURE_SCRIPT_ABS" --json "$ROOT_DIR/$out_file" -- \
      cargo run --release --bin noir-r1cs prove "./noir-proof-scheme_${log}.nps" "./Prover_${log}.toml" -o "./noir-proof_${log}.np"
  )
  echo "Saved: $out_file"
done

# Keccak-f-perm measurements
for log in "${KECCAK_SIZES[@]}"; do
  echo "--- Keccak-f-perm LOG=$log ---"
  scheme_file="$CIRCUIT_KECCAK_PERM_DIR/noir-proof-scheme_${log}.nps"
  inputs_file="$CIRCUIT_KECCAK_PERM_DIR/Prover_${log}.toml"
  if [[ ! -f "$scheme_file" || ! -f "$inputs_file" ]]; then
    echo "Error: Missing scheme or inputs for LOG=$log: $scheme_file / $inputs_file" >&2
    exit 1
  fi

  out_file="$RESULTS_DIR/provekit_keccak_f_perm_log${log}.json"
  echo "Measuring proving RAM..."
  (
    cd "$CIRCUIT_KECCAK_PERM_DIR"
    "$MEASURE_SCRIPT_ABS" --json "$ROOT_DIR/$out_file" -- \
      cargo run --release --bin noir-r1cs prove "./noir-proof-scheme_${log}.nps" "./Prover_${log}.toml" -o "./noir-proof_${log}.np"
  )
  echo "Saved: $out_file"
done

echo "Done. Results in $RESULTS_DIR"