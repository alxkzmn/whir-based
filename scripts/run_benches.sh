#!/usr/bin/env bash
set -euo pipefail

# Parameters
export LOG_B=8       # HyperPlonk example (2^8 = 256 elements ≈ 2 KiB)
export LOG_N_ROWS=4  # Whirlaway example (16 rows ≈ 2 KiB)
export RUST_LOG=warn  # suppress most tracing logs

# Build and run HyperPlonk Poseidon2 benchmark
#printf '\nRunning HyperPlonk Poseidon2 benchmark...\n'
#cargo run --release --manifest-path p3-playground/hyperplonk/Cargo.toml --example koala_bear_poseidon2 --quiet

# Build and run HyperPlonk Keccak benchmark
printf '\nRunning HyperPlonk Keccak benchmark...\n'
cargo run --release --manifest-path p3-playground/hyperplonk/Cargo.toml --example koala_bear_keccak --quiet

# Build and run Whirlaway Poseidon2 benchmark
#printf '\nRunning Whirlaway Poseidon2 benchmark...\n'
#cargo run --release --manifest-path Whirlaway/Cargo.toml --quiet

# Build and run Whirlaway Keccak benchmark
#printf '\nRunning Whirlaway Keccak benchmark...\n'
#WHIR_BENCH=keccak cargo run --release --manifest-path Whirlaway/Cargo.toml --quiet

# Run ProveKit poseidon-var benchmark via divan
# Precompile the Noir circuit (once)
#pushd ProveKit/noir-examples/poseidon-var >/dev/null
#nargo compile --silence-warnings
#popd >/dev/null

# Run ProveKit keccak-f-perm benchmark via divan (256 permutations to match HyperPlonk)
# Precompile the Noir circuit (once)
pushd ProveKit/noir-examples/keccak-f-perm >/dev/null
nargo compile --silence-warnings
popd >/dev/null

printf '\nRunning ProveKit benchmarks...\n'
RUSTFLAGS="-A warnings" cargo bench --manifest-path ProveKit/noir-r1cs/Cargo.toml --bench keccak_f_perm -- --nocapture # --bench poseidon_var

printf '\nAll benchmarks completed.\n' 