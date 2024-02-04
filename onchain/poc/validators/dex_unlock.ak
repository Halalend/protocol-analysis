use aiken/string.{to_bytearray}
use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, ScriptContext, Spend, Transaction,
  TransactionId,
}
use aiken/transaction/credential.{Address, from_script, from_verification_key}
use aiken/transaction/value.{from_lovelace}
use poc/test_utils.{
  create_spectrum_test_pool_utxo, spectrum_output_to_input,
  spectrum_test_script_address,
}
use poc/utils.{Datum, can_unlock}

type Redeemer {
  msg: Int,
}

validator(dex_address: Address) {
  fn unlock_collateral(
    datum: Datum,
    redeemer: Redeemer,
    ctx: ScriptContext,
  ) -> Bool {
    trace string.from_int(redeemer.msg)
    when ctx.purpose is {
      Spend(spend_ref) -> can_unlock(spend_ref, ctx, datum, dex_address)
      _ -> False
    }
  }
}

test can_unlock_collateral() {
  // Test Spectrum Pool UTXO
  let spectrum_ada_usd_pool_utxo =
    create_spectrum_test_pool_utxo(
      None,
      8_000,
      Some(to_bytearray(@"usd")),
      10_000,
    )
  let spectrum_ada_usd_pool_utxo_input =
    spectrum_output_to_input(spectrum_ada_usd_pool_utxo)

  let datum =
    Datum {
      owner: #"00000000000000000000000000000000000000000000000000000000",
      target_value: 10_000,
    }
  // Target USD value of Locked Asset. Say locked ADA is 100 and the exchange rate is 0.8 USD per ADA then the value is 80 USD
  let redeemer = Redeemer { msg: 42 }
  let placeholder_utxo =
    OutputReference {
      transaction_id: TransactionId(
        #"00000000000000000000000000000000000000000000000000000000",
      ),
      output_index: 0,
    }

  let placeholder_input =
    Input {
      output_reference: placeholder_utxo,
      output: Output {
        address: from_verification_key(
          #"00000000000000000000000000000000000000000000000000000000",
        ),
        value: from_lovelace(8_000),
        datum: InlineDatum(datum),
        reference_script: None,
      },
    }

  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder()
        |> fn(transaction) {
             Transaction {
               ..transaction,
               inputs: [placeholder_input],
               extra_signatories: [datum.owner],
               reference_inputs: [spectrum_ada_usd_pool_utxo_input],
             }
           },
    }
  // Script Context
  unlock_collateral(
    from_script(spectrum_test_script_address),
    datum,
    redeemer,
    context,
  )
}

test cant_unlock_when_different_dex_address() fail {
  // Test Spectrum Pool UTXO
  let spectrum_ada_usd_pool_utxo =
    create_spectrum_test_pool_utxo(
      None,
      8_000,
      Some(to_bytearray(@"usd")),
      10_000,
    )
  let spectrum_ada_usd_pool_utxo_input =
    spectrum_output_to_input(spectrum_ada_usd_pool_utxo)

  let different_spectrum_address =
    #"0000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000003"

  let datum =
    Datum {
      owner: #"00000000000000000000000000000000000000000000000000000000",
      target_value: 10_000,
    }
  // Target USD value of Locked Asset. Say locked ADA is 100 and the exchange rate is 0.8 USD per ADA then the value is 80 USD
  let redeemer = Redeemer { msg: 42 }
  let placeholder_utxo =
    OutputReference {
      transaction_id: TransactionId(
        #"00000000000000000000000000000000000000000000000000000000",
      ),
      output_index: 0,
    }

  let placeholder_input =
    Input {
      output_reference: placeholder_utxo,
      output: Output {
        address: from_verification_key(
          #"00000000000000000000000000000000000000000000000000000000",
        ),
        value: from_lovelace(8_000),
        datum: InlineDatum(datum),
        reference_script: None,
      },
    }

  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder()
        |> fn(transaction) {
             Transaction {
               ..transaction,
               inputs: [placeholder_input],
               extra_signatories: [datum.owner],
               reference_inputs: [spectrum_ada_usd_pool_utxo_input],
             }
           },
    }
  // Script Context
  unlock_collateral(
    from_script(different_spectrum_address),
    datum,
    redeemer,
    context,
  )
}

test cant_unlock_when_current_is_below_target() fail {
  // Test Spectrum Pool UTXO
  let spectrum_ada_usd_pool_utxo =
    create_spectrum_test_pool_utxo(
      None,
      8_000,
      Some(to_bytearray(@"usd")),
      7_000,
    )
  let spectrum_ada_usd_pool_utxo_input =
    spectrum_output_to_input(spectrum_ada_usd_pool_utxo)

  let datum =
    Datum {
      owner: #"00000000000000000000000000000000000000000000000000000000",
      target_value: 10_000,
    }
  // Target USD value of Locked Asset. Say locked ADA is 100 and the exchange rate is 0.8 USD per ADA then the value is 80 USD
  let redeemer = Redeemer { msg: 42 }
  let placeholder_utxo =
    OutputReference {
      transaction_id: TransactionId(
        #"00000000000000000000000000000000000000000000000000000000",
      ),
      output_index: 0,
    }

  let placeholder_input =
    Input {
      output_reference: placeholder_utxo,
      output: Output {
        address: from_verification_key(
          #"00000000000000000000000000000000000000000000000000000000",
        ),
        value: from_lovelace(8_000),
        datum: InlineDatum(datum),
        reference_script: None,
      },
    }

  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder()
        |> fn(transaction) {
             Transaction {
               ..transaction,
               inputs: [placeholder_input],
               extra_signatories: [datum.owner],
               reference_inputs: [spectrum_ada_usd_pool_utxo_input],
             }
           },
    }
  // Script Context
  unlock_collateral(
    from_script(spectrum_test_script_address),
    datum,
    redeemer,
    context,
  )
}

test can_unlock_when_current_is_above_target() {
  // Test Spectrum Pool UTXO
  let spectrum_ada_usd_pool_utxo =
    create_spectrum_test_pool_utxo(
      None,
      3000,
      Some(to_bytearray(@"usd")),
      7_000,
    )
  let spectrum_ada_usd_pool_utxo_input =
    spectrum_output_to_input(spectrum_ada_usd_pool_utxo)

  let datum =
    Datum {
      owner: #"00000000000000000000000000000000000000000000000000000000",
      target_value: 10_000,
    }
  // Target USD value of Locked Asset. Say locked ADA is 100 and the exchange rate is 0.8 USD per ADA then the value is 80 USD
  let redeemer = Redeemer { msg: 42 }
  let placeholder_utxo =
    OutputReference {
      transaction_id: TransactionId(
        #"00000000000000000000000000000000000000000000000000000000",
      ),
      output_index: 0,
    }

  let placeholder_input =
    Input {
      output_reference: placeholder_utxo,
      output: Output {
        address: from_verification_key(
          #"00000000000000000000000000000000000000000000000000000000",
        ),
        value: from_lovelace(8_000),
        datum: InlineDatum(datum),
        reference_script: None,
      },
    }

  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder()
        |> fn(transaction) {
             Transaction {
               ..transaction,
               inputs: [placeholder_input],
               extra_signatories: [datum.owner],
               reference_inputs: [spectrum_ada_usd_pool_utxo_input],
             }
           },
    }
  // Script Context
  unlock_collateral(
    from_script(spectrum_test_script_address),
    datum,
    redeemer,
    context,
  )
}
