use aiken/hash.{Blake2b_256, Hash}
use aiken/transaction/credential.{Address}
use poc/types.{AssetClass, VerificationKeyHash}

pub type Datum {
  owner: VerificationKeyHash,
  target_value: Int,
}

pub type MinswapProfitSharing {
  fee_to: Address,
  fee_to_datum_hash: Hash<Blake2b_256, Data>,
}

pub type SpectrumPoolDatum {
  pool_nft: AssetClass,
  pool_x: AssetClass,
  pool_y: AssetClass,
  pool_lq: AssetClass,
  fee_num: Int,
  stake_admin_policy: List<ByteArray>,
  lq_bound: Int,
}

pub type MinswapPoolDatum {
  coin_a: AssetClass,
  coin_b: AssetClass,
  total_liquidity: Int,
  root_k_last: Int,
  profit_sharing: Option<MinswapProfitSharing>,
}
