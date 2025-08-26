#!/usr/bin/env bash
set -euo pipefail

# Parameters
export LOG_B=8       # HyperPlonk example (2^8 = 256 elements ≈ 2 KiB)
export LOG_N_ROWS=4  # Whirlaway example (16 rows ≈ 2 KiB)
export RUST_LOG=warn  # suppress most tracing logs

#Build and run HyperPlonk Poseidon2 benchmark
printf '\nRunning HyperPlonk Poseidon2 benchmark...\n'
cargo bench --manifest-path p3-playground/hyperplonk/Cargo.toml --bench poseidon2_proof --features bench

# Build and run HyperPlonk Keccak benchmark
printf '\nRunning HyperPlonk Keccak benchmark...\n'
cargo bench --manifest-path p3-playground/hyperplonk/Cargo.toml --bench keccak_proof --features bench

# Build and run Whirlaway Poseidon2 benchmark
printf '\nRunning Whirlaway Poseidon2 benchmark...\n'
cargo bench --manifest-path Whirlaway/Cargo.toml --bench poseidon2_proof

# Build and run Whirlaway Keccak benchmark
#printf '\nRunning Whirlaway Keccak benchmark...\n'
#WHIR_BENCH=keccak cargo run --release --manifest-path Whirlaway/Cargo.toml --quiet
