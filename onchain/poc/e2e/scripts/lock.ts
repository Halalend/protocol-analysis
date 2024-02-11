import { Data } from "https://deno.land/x/lucid@0.10.7/mod.ts";
import {
  SpendingValidator,
  TxHash,
} from "https://deno.land/x/lucid@0.8.3/mod.ts";
import { MyDatum } from "../types.ts";
import { lucid, readValidator } from "../utils.ts";

const validator = await readValidator();

const publicKeyHash = lucid.utils.getAddressDetails(
  await lucid.wallet.address(),
).paymentCredential?.hash;

const datum: MyDatum = {
  owner: publicKeyHash!,
  target: 100n,
};

const lock_amount = 5000000n;

const txHash = await lock(lock_amount, {
  into: validator,
  datum: Data.to(datum, MyDatum),
});

await lucid.awaitTx(txHash);

console.log(`${lock_amount} ADA locked into the contract at:
      Tx ID: ${txHash}
      Datum: ${datum}
  `);

async function lock(
  lovelace: bigint,
  { into, datum }: { into: SpendingValidator; datum: string },
): Promise<TxHash> {
  const contractAddress = lucid.utils.validatorToAddress(into);

  const tx = await lucid
    .newTx()
    .payToContract(contractAddress, { inline: datum }, { lovelace })
    .complete();

  const signedTx = await tx.sign().complete();

  return signedTx.submit();
}
