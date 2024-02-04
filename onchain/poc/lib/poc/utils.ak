use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/string.{concat, from_int}
use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, ScriptContext, Transaction,
}
use aiken/transaction/credential.{Address, VerificationKey}
use aiken/transaction/value.{AssetName, PolicyId, lovelace_of, quantity_of}

pub const precision_factor = 10_000

pub type SpectrumLiquidityPoolDatum {
  asset_a_policy: PolicyId,
  asset_a_name: AssetName,
  asset_b_policy: PolicyId,
  asset_b_name: AssetName,
}

pub type Datum {
  owner: Hash<Blake2b_224, VerificationKey>,
  target_value: Int,
}

pub fn calculate_rate(asset_a_value, asset_b_value) -> Int {
  let rate = asset_b_value * precision_factor / asset_a_value
  rate
}

pub fn to_sepectrum_datum(data: Data) -> SpectrumLiquidityPoolDatum {
  expect spectrum_datum: SpectrumLiquidityPoolDatum = data
  spectrum_datum
}

pub fn must_be_signed_by(transaction: Transaction, vk: VerificationKey) {
  list.has(transaction.extra_signatories, vk)
}

pub fn input_must_be_from_script_address(input: Input, script_address: Address) {
  input.output.address == script_address
}

pub fn can_unlock(
  self_ref: OutputReference,
  ctx: ScriptContext,
  datum: Datum,
  dex_address: Address,
) {
  expect Some(dex_ref_input) = ctx.transaction.reference_inputs |> list.head()
  expect Some(self) = ctx.transaction.inputs |> transaction.find_input(self_ref)
  and {
    must_be_signed_by(ctx.transaction, datum.owner),
    input_must_be_from_script_address(dex_ref_input, dex_address)?,
    must_be_greater_than_target_value(self, dex_ref_input, datum.target_value),
  }
}

pub fn must_be_greater_than_target_value(
  self: Input,
  dex_ref_input: Input,
  target_value: Int,
) {
  // This is the value of the locked asset in the validator
  when dex_ref_input.output.datum is {
    InlineDatum(dex_datum) -> {
      // Get the spectrum datum
      let spectrum_datum = to_sepectrum_datum(dex_datum)

      // Extract the values of Liquidity Pool
      let pool_ada_value = dex_ref_input.output.value |> lovelace_of()
      let asset_b_policy = spectrum_datum.asset_b_policy
      let asset_b_name = spectrum_datum.asset_b_name
      let pool_asset_b_value =
        dex_ref_input.output.value |> quantity_of(asset_b_policy, asset_b_name)

      // Calculate Current Exchange Rate
      let current_rate = calculate_rate(pool_ada_value, pool_asset_b_value)
      trace concat(@"Current Exchange Rate: ", from_int(current_rate))

      // Calculate the value of the locked asset in ASSET_B (USD)
      let ada_locked = lovelace_of(self.output.value)
      let current_value = current_rate * ada_locked
      trace concat(@"Current Locked Value in USD: ", from_int(current_value))

      // Convert the target value into the same precision as the current value
      let target_value = target_value * precision_factor
      trace concat(@"Target Value in USD: ", from_int(target_value))

      // Check if the current value is greater than or equal to the target value
      let target_reached = current_value >= target_value
      target_reached?
    }
    _ -> False
  }
}
