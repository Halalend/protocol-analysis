import * as cbor from "https://deno.land/x/cbor@v1.4.1/index.js";
import {
  Blockfrost,
  fromHex,
  Lucid,
  SpendingValidator,
  toHex,
} from "https://deno.land/x/lucid@0.10.7/mod.ts";

// Lucid Instance
const lucid = await Lucid.new(
  new Blockfrost(
    "https://cardano-mainnet.blockfrost.io/api/v0",
    Deno.env.get("BLOCKFROST_PROJECT_ID"),
  ),
  "Mainnet",
);
lucid.selectWalletFromPrivateKey(
  await Deno.readTextFile("./credentials/me.sk"),
);

// Spending Validator
async function readValidator(): Promise<SpendingValidator> {
  const validator =
    JSON.parse(await Deno.readTextFile("../plutus.json")).validators[0];
  return {
    type: "PlutusV2",
    script: toHex(cbor.encode(fromHex(validator.compiledCode))),
  };
}

export { cbor, lucid, readValidator };
