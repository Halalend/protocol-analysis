use aiken/cbor
use aiken/list
use aiken/string
use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction, TransactionId,
}
use aiken/transaction/credential.{Address, VerificationKey}
use aiken/transaction/value.{Value}
use poc/constants.{minswap_lp_sh, precision_factor, spectrum_lp_sh}
use poc/datums.{MinswapPoolDatum, SpectrumPoolDatum}
use poc/types.{AssetClass, PoolReference}

/// Check if a transaction is signed by a given verification key
pub fn must_be_signed_by(transaction: Transaction, vk: VerificationKey) {
  list.has(transaction.extra_signatories, vk)
}

/// Find all outputs with a given address
pub fn find_outputs(outputs: List<Output>, address: Address) -> List<Output> {
  outputs |> list.filter(fn(output) { output.address == address })
}

/// Merge all values in a list of outputs
pub fn merge_values(outputs: List<Output>) -> Value {
  outputs
    |> list.foldl(
         value.zero(),
         fn(output, acc) { acc |> value.merge(output.value) },
       )
}

/// Pure math calculation of exchange rate between two assets
pub fn calculate_rate(asset_a_value, asset_b_value) -> Int {
  let rate = asset_b_value * precision_factor / asset_a_value
  rate
}

/// Calculate the current exchange rate of a given reference input
/// The exchange rate is calculated based on the current state of the pool
pub fn calculate_current_pool_rate(
  input: Input,
  pool_datum: Data,
  pool_type: Int,
) -> Int {
  when pool_type is {
    0 -> {
      trace string.concat(@"SpectrumPoolDatum: ", cbor.diagnostic(pool_datum))
      expect datum: SpectrumPoolDatum = pool_datum
      let ada_value = input.output.value |> value.lovelace_of()
      let is_x_ada = datum.pool_x.policy_id == ""
      let other_asset =
        if is_x_ada {
          datum.pool_y
        } else {
          datum.pool_x
        }
      let other_value =
        input.output.value
          |> value.quantity_of(other_asset.policy_id, other_asset.asset_name)
      calculate_rate(ada_value, other_value)
    }
    1 -> {
      trace string.concat(@"MinswapPoolDatum: ", cbor.diagnostic(pool_datum))
      expect datum: MinswapPoolDatum = pool_datum
      let ada_value = input.output.value |> value.lovelace_of()
      let is_a_ada = datum.coin_a.policy_id == ""
      let other_asset =
        if is_a_ada {
          datum.coin_b
        } else {
          datum.coin_a
        }
      let other_value =
        input.output.value
          |> value.quantity_of(other_asset.policy_id, other_asset.asset_name)
      calculate_rate(ada_value, other_value)
    }
    _ -> 0
  }
}

/// Check if the current locked value is greater than
/// or equal to the target value specified in the Datum 
/// in terms of asset_b
pub fn must_be_greater_than_target_value(
  locked_value: Value,
  target_value: Int,
  reference_inputs: List<Input>,
  pool_refs: List<PoolReference>,
) {
  let locked_ada = locked_value |> value.lovelace_of()
  let total_rate =
    pool_refs
      |> list.foldl(
           0,
           fn(ref, acc) {
             expect Some(input) =
               reference_inputs
                 |> transaction.find_input(ref.output_ref)
             expect InlineDatum(datum) = input.output.datum
             acc + calculate_current_pool_rate(input, datum, ref.pool_type)
           },
         )
  let avg_rate = total_rate / ( pool_refs |> list.length() )
  let locked_ada_value = locked_ada * avg_rate
  let target_ada_value = target_value * precision_factor

  trace string.concat(@"locked_ada: ", string.from_int(locked_ada))
  trace string.concat(@"total_rate: ", string.from_int(total_rate))
  trace string.concat(@"avg_rate: ", string.from_int(avg_rate))
  trace string.concat(@"locked_ada_value: ", string.from_int(locked_ada_value))
  trace string.concat(@"target_ada_value: ", string.from_int(target_ada_value))

  locked_ada_value >= target_ada_value
}

test check_must_be_greater_than_target_value() {
  let locked_value = value.from_lovelace(100)
  let target_value = 50
  let minswap_output_ref =
    OutputReference { transaction_id: TransactionId("tx1"), output_index: 0 }
  let spectrum_output_ref =
    OutputReference { transaction_id: TransactionId("tx2"), output_index: 0 }
  let reference_inputs =
    [
      Input {
        output: Output {
          datum: InlineDatum(
            MinswapPoolDatum {
              coin_a: AssetClass { policy_id: "", asset_name: "" },
              coin_b: AssetClass { policy_id: "111", asset_name: "1" },
              total_liquidity: 1000,
              root_k_last: 10,
              profit_sharing: None,
            },
          ),
          value: value.from_lovelace(5000)
            |> value.merge(value.from_asset("111", "1", 5000)),
          reference_script: None,
          address: credential.from_script(minswap_lp_sh),
        },
        output_reference: minswap_output_ref,
      },
      Input {
        output: Output {
          datum: InlineDatum(
            SpectrumPoolDatum {
              pool_nft: AssetClass { policy_id: "", asset_name: "" },
              pool_x: AssetClass { policy_id: "", asset_name: "" },
              pool_y: AssetClass { policy_id: "111", asset_name: "1" },
              pool_lq: AssetClass { policy_id: "", asset_name: "" },
              fee_num: 10,
              stake_admin_policy: [],
              lq_bound: 100000,
            },
          ),
          value: value.from_lovelace(5000)
            |> value.merge(value.from_asset("111", "1", 1000)),
          reference_script: None,
          address: credential.from_script(spectrum_lp_sh),
        },
        output_reference: spectrum_output_ref,
      },
    ]

  let pool_refs =
    [
      PoolReference { output_ref: minswap_output_ref, pool_type: 1 },
      PoolReference { output_ref: spectrum_output_ref, pool_type: 0 },
    ]

  must_be_greater_than_target_value(
    locked_value,
    target_value,
    reference_inputs,
    pool_refs,
  )
}
