#!/usr/bin/env bash
set -euo pipefail

# Parameters
export LOG_B=8       # HyperPlonk example (2^8 = 256 elements ≈ 2 KiB)
export LOG_N_ROWS=4  # Whirlaway example (16 rows ≈ 2 KiB)
export RUST_LOG=warn  # suppress most tracing logs

# Build and run HyperPlonk Poseidon2 benchmark
printf '\nRunning HyperPlonk Poseidon2 benchmark...\n'
cargo run --release --manifest-path p3-playground/hyperplonk/Cargo.toml --example koala_bear_poseidon2 --quiet

# Build and run Whirlaway Poseidon2 benchmark
printf '\nRunning Whirlaway Poseidon2 benchmark...\n'
cargo run --release --manifest-path Whirlaway/Cargo.toml --quiet

# Run Noir circuits with noir-r1cs backend
run_noir() {
  local CIRCUIT_DIR="$1"
  printf "\nRunning Noir circuit in %s...\n" "$CIRCUIT_DIR"
  (
    cd "$CIRCUIT_DIR"
    # 1. Compile the circuit
    nargo compile --silence-warnings
    # 2. Prepare proof scheme (.nps)
    cargo run --quiet --release --manifest-path ../../noir-r1cs/Cargo.toml --bin noir-r1cs -- \
      prepare ./target/basic.json -o ./scheme.nps
    # 3. Generate proof (we don’t verify here to save time)
    cargo run --quiet --release --manifest-path ../../noir-r1cs/Cargo.toml --bin noir-r1cs -- \
      prove ./scheme.nps ./Prover.toml -o ./proof.np
  )
}

run_noir ProveKit/noir-examples/poseidon-rounds
run_noir ProveKit/noir-examples/poseidon-var

printf '\nAll Poseidon benchmarks completed.\n' 