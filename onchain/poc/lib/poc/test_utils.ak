use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, TransactionId,
}
use aiken/transaction/credential.{from_script}
use aiken/transaction/value.{from_asset, from_lovelace, merge}
use poc/utils.{SpectrumLiquidityPoolDatum}

pub const spectrum_test_script_address =
  #"0000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000002"

pub const spectrum_test_policy_id =
  #"f4c9f9c4252d86702c2f4c2e49e6648c7cffe3c8f2b6b7d779788f50"

pub fn create_spectrum_test_pool_utxo(
  asset_a: Option<ByteArray>,
  asset_a_quantity: Int,
  asset_b: Option<ByteArray>,
  asset_b_quantity: Int,
) -> Output {
  let (asset_a_policy, asset_a_name, asset_a_value) =
    when asset_a is {
      Some(a) ->
        (
          spectrum_test_policy_id,
          a,
          from_asset(spectrum_test_policy_id, a, asset_a_quantity),
        )
      None -> (#"", #"", from_lovelace(asset_a_quantity))
    }

  let (asset_b_policy, asset_b_name, asset_b_value) =
    when asset_b is {
      Some(b) ->
        (
          spectrum_test_policy_id,
          b,
          from_asset(spectrum_test_policy_id, b, asset_b_quantity),
        )
      None -> (#"", #"", from_lovelace(asset_b_quantity))
    }

  let datum =
    SpectrumLiquidityPoolDatum {
      asset_a_policy,
      asset_a_name,
      asset_b_policy,
      asset_b_name,
    }

  let value = merge(asset_a_value, asset_b_value)

  Output {
    address: from_script(spectrum_test_script_address),
    value,
    datum: InlineDatum(datum),
    reference_script: None,
  }
}

pub fn spectrum_output_to_input(output: Output) -> Input {
  let output_reference =
    OutputReference { transaction_id: TransactionId("111"), output_index: 0 }
  Input { output_reference, output }
}
