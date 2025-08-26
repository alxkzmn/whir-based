
#!/usr/bin/env bash

# Parse args to know if need to generate circuits or not
if [ "$1" == "generate" ]; then
   GENERATE_CIRCUITS=true
else
   GENERATE_CIRCUITS=false
fi

pushd ProveKit/noir-examples/poseidon-var >/dev/null
if [ "$GENERATE_CIRCUITS" == true ]; then
    ./generate_circuits.sh
fi

for log_size in 6 7 8 9; do
    command_string="cargo run --release --bin noir-r1cs prove ./noir-proof-scheme_${log_size}.nps ./Prover_${log_size}.toml -o ./noir-proof_${log_size}.np"
    #hyperfine --runs 10 "$command_string" 
done 
popd >/dev/null

pushd ProveKit/noir-examples/keccak-f-perm >/dev/null
if [ "$GENERATE_CIRCUITS" == true ]; then
    ./generate_circuits.sh
fi

for log_size in 5 6 7 8; do
    command_string="cargo run --release --bin noir-r1cs prove ./noir-proof-scheme_${log_size}.nps ./Prover_${log_size}.toml -o ./noir-proof_${log_size}.np"
    hyperfine --runs 10 "$command_string" 
done 
popd >/dev/null