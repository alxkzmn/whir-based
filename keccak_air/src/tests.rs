use alloc::vec::Vec;
use rand::rngs::SmallRng;
use rand::{Rng, SeedableRng};

use p3_matrix::dense::RowMajorMatrix;
use p3_matrix::Matrix;

use crate::generate_trace_rows as local_generate;
use crate::{output_limb as local_output_limb, NUM_ROUNDS as LOCAL_NUM_ROUNDS};

// Upstream types
use p3k_keccak_air as upstream;
use upstream::output_limb as upstream_output_limb;
use upstream::NUM_ROUNDS as UPSTREAM_NUM_ROUNDS;

#[test]
fn traces_match_for_random_inputs() {
    type F = p3k_goldilocks::Goldilocks;

    let mut rng = SmallRng::seed_from_u64(1);

    // Generate a few permutations (multiple of 24 rows needed by upstream design)
    let num_perms = 8usize; // small for test speed

    let inputs: Vec<[u64; 25]> = (0..num_perms)
        .map(|_| {
            let mut a = [0u64; 25];
            for i in 0..25 {
                a[i] = rng.gen();
            }
            a
        })
        .collect();

    // Local trace using explicit inputs
    let local_trace: RowMajorMatrix<F> = local_generate::<F>(inputs.clone(), 0);

    // Upstream trace using the same explicit inputs
    let upstream_trace: RowMajorMatrix<F> = upstream::generate_trace_rows::<F>(inputs, 0);

    // Compare only Keccak-f outputs (rate limbs) at the last row per permutation
    assert_eq!(LOCAL_NUM_ROUNDS, UPSTREAM_NUM_ROUNDS);
    const RATE_LIMBS: usize = 1088 / 16;
    for p in 0..num_perms {
        let row = p * LOCAL_NUM_ROUNDS + (LOCAL_NUM_ROUNDS - 1);
        for i in 0..RATE_LIMBS {
            let col_local = local_output_limb(i);
            let col_up = upstream_output_limb(i);
            let a = local_trace.values[row * local_trace.width() + col_local];
            let b = upstream_trace.values[row * upstream_trace.width() + col_up];
            assert_eq!(a, b, "mismatch at perm {}, limb {}", p, i);
        }
    }
}
