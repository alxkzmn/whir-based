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
