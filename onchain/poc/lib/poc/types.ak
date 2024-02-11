use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction.{OutputReference}
use aiken/transaction/credential.{Script, VerificationKey}
use aiken/transaction/value.{AssetName, PolicyId}

pub type AssetClass {
  policy_id: PolicyId,
  asset_name: AssetName,
}

pub type ScriptHash =
  Hash<Blake2b_224, Script>

pub type VerificationKeyHash =
  Hash<Blake2b_224, VerificationKey>

pub type PoolReference {
  output_ref: OutputReference,
  pool_type: Int,
}
