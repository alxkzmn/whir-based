# WHIR-Based Proving Systems Research

## Motivation

World positions ProveKit (Spartan+WHIR) as [the best proving system](https://x.com/DCbuild3r/status/1935317445075488933), but can there be something better? E.g., Hyperplonk paper is claiming better benchmarks than Spartan. Also, there are newer iterations of Spartan. Therefore, we'd like to compare the performance of the original ProveKit vs other multilinear PIOP with WHIR PCS.

Why WHIR-based? Because WHIR

- doesn't require setup (is transparent);
- [is verifiable onchain](https://ethresear.ch/t/on-the-gas-efficiency-of-the-whir-polynomial-commitment-scheme/21301) (using **sol-whir**);
- is post-quantum-sound.

## Implementations Under Comparison

- https://github.com/worldfnd/ProveKit (Spartan+WHIR)
- https://github.com/han0110/p3-playground (Hyperplonk+WHIR)
- https://github.com/TomWambsgans/Whirlaway (SuperSpartan+WHIR)

## Running the benchmarks

```bash
./scripts/run_benches.sh
```

## Measuring Prover RAM

- HyperPlonk Keccak

```bash
VERIFY=0 LOG_B=7 scripts/measure_mem.sh --json hp_keccak.json -- \
  cargo run --manifest-path p3-playground/hyperplonk/Cargo.toml --release --example koala_bear_keccak
```

- HyperPlonk Poseidon2

```bash
VERIFY=0 LOG_B=7 scripts/measure_mem.sh --json hp_poseidon2.json -- \
  cargo run --manifest-path p3-playground/hyperplonk/Cargo.toml --release --example koala_bear_poseidon2
```

- Whirlaway Poseidon2

```bash
VERIFY=0 scripts/measure_mem.sh --json wa_poseidon2.json -- \
  cargo run --manifest-path Whirlaway/Cargo.toml --release -- --env WHIR_BENCH=poseidon2 --env LOG_N_ROWS=6
```

ProveKit:

```bash
./scripts/run_provekit_ram.sh -c poseidon-var -s "6 7 8 9"
```
