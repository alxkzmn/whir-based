#!/usr/bin/env bash
set -euo pipefail

# Parameters
export LOG_B=8       # HyperPlonk example (2^8 = 256 elements ≈ 2 KiB)
export LOG_N_ROWS=4  # Whirlaway example (16 rows ≈ 2 KiB)
export RUST_LOG=warn  # suppress most tracing logs

SYSTEM=""
CIRCUIT=""

usage() {
cat <<'EOF'
Usage: scripts/run_benches.sh [-s|--system hyperplonk|whirlaway] [-c|--circuit poseidon|keccak]
Run benchmarks selectively. Defaults: runs all if no filters are provided.

Examples:
  scripts/run_benches.sh
  scripts/run_benches.sh --system hyperplonk
  scripts/run_benches.sh --circuit keccak
  scripts/run_benches.sh -s whirlaway -c poseidon
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "${1:-}" in
    -s|--system)
      [[ $# -ge 2 ]] || { echo "Error: --system requires a value" >&2; usage; exit 1; }
      SYSTEM="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
      case "$SYSTEM" in
        hyperplonk|whirlaway) ;;
        *) echo "Error: invalid system '$SYSTEM'. Use hyperplonk or whirlaway." >&2; usage; exit 1 ;;
      esac
      shift 2
      ;;
    -c|--circuit)
      [[ $# -ge 2 ]] || { echo "Error: --circuit requires a value" >&2; usage; exit 1; }
      CIRCUIT="$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')"
      case "$CIRCUIT" in
        poseidon|keccak) ;;
        *) echo "Error: invalid circuit '$CIRCUIT'. Use poseidon or keccak." >&2; usage; exit 1 ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'" >&2
      usage
      exit 1
      ;;
  esac
done

should_run_system() { [[ -z "$SYSTEM" || "$SYSTEM" == "$1" ]]; }
should_run_circuit() { [[ -z "$CIRCUIT" || "$CIRCUIT" == "$1" ]]; }

# HyperPlonk
if should_run_system "hyperplonk"; then
  if should_run_circuit "poseidon"; then
    printf '\nRunning HyperPlonk Poseidon2 benchmark...\n'
    RUSTFLAGS=-Ctarget-cpu=native cargo bench --manifest-path p3-playground/hyperplonk/Cargo.toml --bench poseidon2_proof --features bench
  fi
  if should_run_circuit "keccak"; then
    printf '\nRunning HyperPlonk Keccak benchmark...\n'
    RUSTFLAGS=-Ctarget-cpu=native cargo bench --manifest-path p3-playground/hyperplonk/Cargo.toml --bench keccak_proof --features bench
  fi
fi

# Whirlaway
if should_run_system "whirlaway"; then
  if should_run_circuit "poseidon"; then
    printf '\nRunning Whirlaway Poseidon2 benchmark...\n'
    cargo bench --manifest-path Whirlaway/Cargo.toml --bench poseidon2_proof
  fi
  if should_run_circuit "keccak"; then
    printf '\nRunning Whirlaway Keccak benchmark...\n'
    cargo bench --manifest-path Whirlaway/Cargo.toml --bench keccak_proof
  fi
fi
