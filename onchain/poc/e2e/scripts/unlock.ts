import {
  Data,
  OutRef,
  SpendingValidator,
  TxHash,
  UTxO,
} from "https://deno.land/x/lucid@0.10.7/mod.ts";
import {
  ADA_IUSD_NFT_SPECTRUM,
  ADA_USDC_NFT_SPECTRUM,
  SPECTRUM_LP_ADDRESS,
} from "../constants.ts";
import { MyRedeemer } from "../types.ts";
import { lucid, readValidator } from "../utils.ts";

const validator = await readValidator();
const contractAddress = lucid.utils.validatorToAddress(validator);
const validatorUtxo = await lucid.provider.getUtxos(contractAddress);

// Fetch Pool Liquidity UTXOs
const ada_iusd_utxo_spectrum = await lucid.provider.getUtxosWithUnit(
  SPECTRUM_LP_ADDRESS,
  ADA_IUSD_NFT_SPECTRUM,
);
const ada_usdc_utxo_spectrum = await lucid.provider.getUtxosWithUnit(
  SPECTRUM_LP_ADDRESS,
  ADA_USDC_NFT_SPECTRUM,
);

// Redeemer
const unlockRedeemer: MyRedeemer = {
  Unlock: {
    pool_references: [
      {
        output_ref: {
          transaction_id: {
            hash: ada_iusd_utxo_spectrum[0].txHash,
          },
          output_index: BigInt(ada_iusd_utxo_spectrum[0].outputIndex), // Example integer value
        },
        pool_type: 0n,
      },
      {
        output_ref: {
          transaction_id: {
            hash: ada_usdc_utxo_spectrum[0].txHash,
          },
          output_index: BigInt(ada_usdc_utxo_spectrum[0].outputIndex), // Example integer value
        },
        pool_type: 0n,
      },
    ],
  },
};
const redeemer = Data.to(unlockRedeemer, MyRedeemer);

// Build Transaction
const txHash = await unlock(validatorUtxo[0], [
  ada_iusd_utxo_spectrum[0],
  ada_usdc_utxo_spectrum[0],
], {
  from: validator,
  using: redeemer,
});

await lucid.awaitTx(txHash);

console.log(`ADA unlocked from the contract
      Tx ID:    ${txHash}
      Redeemer: ${redeemer}
  `);

/**
 * The `unlock` function is an asynchronous function that takes in a reference, an array of UTxOs, and
 * an object with `from` and `using` properties, and returns a promise that resolves to a transaction
 * hash.
 * @param {OutRef} ref - The `ref` parameter is an `OutRef` which represents the reference to an
 * unspent transaction output (UTxO) that you want to unlock.
 * @param {UTxO[]} reference_inputs - An array of UTxO (Unspent Transaction Output) objects that are
 * used as inputs for the transaction. These inputs are referenced by their OutRef, which is a unique
 * identifier for each UTxO.
 * @param {Object} options - from spending validator using redeemer
 * @returns a Promise that resolves to a TxHash.
 */
async function unlock(
  ref: OutRef,
  reference_inputs: UTxO[],
  { from, using }: { from: SpendingValidator; using: string },
): Promise<TxHash> {
  const [utxo] = await lucid.utxosByOutRef([ref]);

  const tx = await lucid
    .newTx()
    .collectFrom([utxo], using)
    .addSigner(await lucid.wallet.address())
    .readFrom(reference_inputs)
    .attachSpendingValidator(from)
    .complete({
      nativeUplc: false,
    });

  const signedTx = await tx
    .sign()
    .complete();

  return signedTx.submit();
}
