use aiken/transaction.{
  InlineDatum, Input, Output, OutputReference, ScriptContext, Spend, Transaction,
  TransactionId,
}
use aiken/transaction/credential
use aiken/transaction/value
use poc/constants.{minswap_lp_sh, spectrum_lp_sh}
use poc/datums.{Datum, MinswapPoolDatum, SpectrumPoolDatum}
use poc/types.{AssetClass, PoolReference}
use poc/utils.{must_be_greater_than_target_value, must_be_signed_by}

type Redeemer {
  /// Unlock the UTXO, requires a list of pool references
  /// Pool Reference -> output reference and pool type (spectrum, minswap, etc..)
  /// for easier access to the pool's datum and reserves
  Unlock(List<PoolReference>)

  /// Cancel or refund the locked UTXO
  Cancel
}

validator {
  fn unlock(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) -> Bool {
    when redeemer is {
      Unlock(pool_references) -> {
        trace @"Unlocking..."
        expect Spend(self_ref) = ctx.purpose
        expect Some(self) =
          ctx.transaction.inputs |> transaction.find_input(self_ref)

        trace @"Checking if UTXO can be unlocked..."
        // Target value must be reached
        let target_reached =
          self.output.value
            |> must_be_greater_than_target_value(
                 datum.target_value,
                 ctx.transaction.reference_inputs,
                 pool_references,
               )

        trace @"Checking if Tx is signed by the owner..."
        // Tx Must be signed by the owner
        let signed_by_owner =
          ctx.transaction
            |> must_be_signed_by(datum.owner)

        // UTXO can be unlocked if 
        // 1. Target value is reached
        // 2. Tx is signed by the owner
        signed_by_owner && target_reached
      }
      Cancel ->
        ctx.transaction
          |> must_be_signed_by(datum.owner)
    }
  }
}

test must_be_able_to_unlock() {
  let datum = Datum { owner: #"00000000000001", target_value: 100 }
  // Pool References
  let minswap_output_ref =
    OutputReference { transaction_id: TransactionId("tx1"), output_index: 0 }
  let spectrum_output_ref =
    OutputReference { transaction_id: TransactionId("tx2"), output_index: 0 }
  let pool_refs =
    [
      PoolReference { output_ref: minswap_output_ref, pool_type: 1 },
      PoolReference { output_ref: spectrum_output_ref, pool_type: 0 },
    ]

  // Pool Reference Inputs
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
          value: value.from_lovelace(39_811_856_331)
            |> value.merge(value.from_asset("111", "1", 27_253_058_356)),
          reference_script: None,
          address: credential.from_script(minswap_lp_sh),
        },
        output_reference: minswap_output_ref,
      },
      Input {
        output: Output {
          datum: InlineDatum(
            SpectrumPoolDatum {
              pool_nft: AssetClass {
                policy_id: "00000000000001",
                asset_name: "SpectrumPoolNFT",
              },
              pool_x: AssetClass { policy_id: "", asset_name: "" },
              pool_y: AssetClass { policy_id: "111", asset_name: "1" },
              pool_lq: AssetClass {
                policy_id: "00000000000001",
                asset_name: "SpectrumPoolLQ",
              },
              fee_num: 10,
              stake_admin_policy: [],
              lq_bound: 100000,
            },
          ),
          value: value.from_lovelace(1_411_348_286)
            |> value.merge(value.from_asset("111", "1", 76_904_260_317)),
          reference_script: None,
          address: credential.from_script(spectrum_lp_sh),
        },
        output_reference: spectrum_output_ref,
      },
    ]

  // Spend Output Reference
  let spend_output_ref =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }
  let spend_input =
    Input {
      output: Output {
        datum: InlineDatum(datum),
        value: value.from_lovelace(100),
        reference_script: None,
        address: credential.from_verification_key(datum.owner),
      },
      output_reference: spend_output_ref,
    }

  let redeemer = Unlock(pool_refs)
  let context =
    ScriptContext {
      purpose: Spend(spend_output_ref),
      transaction: transaction.placeholder()
        |> fn(transaction) {
             Transaction {
               ..transaction,
               extra_signatories: [datum.owner],
               inputs: [spend_input],
               reference_inputs: reference_inputs,
             }
           },
    }
  unlock(datum, redeemer, context)
}
