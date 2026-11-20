//! Calls every row-source method that `McFollowerRowSource` implements against a running
//! `mc-follower serve` for preview, and prints one line per row in a fixed format, so the output
//! can be compared with direct queries of the server's SQLite database.
//!
//! Usage: `mc-follower-rust-client-check http://127.0.0.1:50051`

use chrono::{Duration, NaiveDateTime};
use db_sync_sqlx::{Address, Asset, AssetName, BlockNumber, EpochNumber, PolicyId, SlotNumber, TxHash};
use midnight_primitives_cnight_observation::{CardanoPosition, TimestampUnixMillis};
use midnight_primitives_mainchain_follower::data_source::candidates_data_source::row_source::{
	self as cds, CandidatesRowSource,
};
use midnight_primitives_mainchain_follower::db::{
	self as mf, CNightObservationRowSource, FederatedAuthorityRowSource, McBlockByHashRowSource,
};
use midnight_primitives_mc_follower::{McFollowerRowSource, proto};
use partner_chains_db_sync_data_sources::row_source::{self as pc, BlockRowSource, BridgeRowSource};
use sidechain_domain::{McBlockHash, UtxoId};

type BoxError = Box<dyn std::error::Error + Send + Sync>;

/// Preview's Midnight main-chain scripts, as in mc-follower's `watchPreset Preview`.
const CNIGHT_POLICY: &str = "d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1";
const MAPPING_VALIDATOR: &str = "addr_test1wplxjzranravtp574s2wz00md7vz9rzpucu252je68u9a8qzjheng";
/// The mapping validator's script hash: the auth token's policy.
const AUTH_TOKEN_POLICY: &str = "7e69087d98fac5869eac14e13dfb6f98228c41e638aa2a59d1f85e9c";
const COUNCIL: (&str, &str) = (
	"addr_test1wzy47zdsq22pg9l48c5v0f835ljdjzkz47sa5za9cehcejcw28k2d",
	"895f09b002941417f53e28c7a4f1a7e4d90ac2afa1da0ba5c66f8ccb",
);
const TECHNICAL_COMMITTEE: (&str, &str) = (
	"addr_test1wptcy7h9rmkhdnhn3jvm6tuhehcq2hhhzntvn00nq79ph8c44v43j",
	"57827ae51eed76cef38c99bd2f97cdf0055ef714d6c9bdf3078a1b9f",
);
const PERMISSIONED_CANDIDATES_POLICY: &str = "24dccfce2576ae6fa7149bc485850656ae6faf9f4158891316773a78";
const COMMITTEE_CANDIDATES: &str = "addr_test1wz5ax0hjvhx2uqef8sqrxnmfywd37hea4truhqxu4yxp9hsvggkfm";
const ICS: &str = "addr_test1wzga9g4tw69twfvpjynyvdyzvpf5f0e88v6hnu9eh9qgdnqaw66xk";
const RESERVE: &str = "addr_test1wzdpdpyev08npr3ktyy9dskvh2v9wk3vphamd6kk60qmjtgftyu2n";
/// Preview's security parameter.
const K: u32 = 432;

fn unhex(s: &str) -> Vec<u8> {
	hex::decode(s).expect("hex constant")
}

fn h(bytes: impl AsRef<[u8]>) -> String {
	hex::encode(bytes)
}

fn time(t: NaiveDateTime) -> String {
	t.format("%Y-%m-%dT%H:%M:%S%.3f").to_string()
}

fn datum(d: Option<&cardano_serialization_lib::PlutusData>) -> String {
	d.map_or("-".to_string(), |d| h(d.to_bytes()))
}

fn pc_block(b: &pc::Block) -> String {
	format!("block {} {} epoch {} slot {} time {}", b.block_no.0, h(b.hash), b.epoch_no.0, b.slot_no.0, time(b.time))
}

fn mf_block(b: &mf::Block) -> String {
	format!(
		"block {} {} epoch {} slot {} time {} txs {}",
		b.block_number.0,
		h(b.hash),
		b.epoch_number.0,
		b.slot_number.0,
		time(b.time),
		b.tx_count
	)
}

fn cds_block(b: &cds::Block) -> String {
	format!("block {} {} epoch {} slot {}", b.block_no.0, h(b.hash), b.epoch_no.0, b.slot_no.0)
}

fn utxo(u: &UtxoId) -> String {
	format!("{}#{}", h(u.tx_hash.0), u.index.0)
}

fn show<T>(name: &str, result: Result<T, impl std::fmt::Debug>, render: impl FnOnce(T) -> Vec<String>) {
	match result {
		Ok(rows) => {
			let lines = render(rows);
			println!("{name}: {} row(s)", lines.len());
			for line in lines {
				println!("  {line}");
			}
		},
		Err(e) => println!("{name}: error: {e:?}"),
	}
}

fn opt<T>(row: Option<T>, render: impl FnOnce(T) -> String) -> Vec<String> {
	row.map(render).into_iter().collect()
}

#[tokio::main]
async fn main() -> Result<(), BoxError> {
	let endpoint = std::env::args().nth(1).unwrap_or_else(|| "http://127.0.0.1:50051".to_string());
	let source = McFollowerRowSource::connect(endpoint.clone()).await?;

	// GetStatus is not behind a row-source trait; call it through the crate's generated client.
	let mut client = proto::mc_follower_client::McFollowerClient::connect(endpoint).await?;
	let status = client.get_status(proto::GetStatusRequest {}).await?.into_inner();
	println!(
		"GetStatus: tip {:?} immutable {:?} start {:?} k {} syncing {} upstream {:?}/{:?} magic {} backfilling {:?}",
		status.tip.as_ref().map(|b| b.block_no),
		status.immutable_tip.as_ref().map(|b| b.block_no),
		status.start_block.as_ref().map(|b| b.block_no),
		status.security_parameter,
		status.syncing,
		status.upstream_tip_slot,
		status.upstream_tip_block_no,
		status.network_magic,
		status.backfilling
	);

	// Block row source
	let tip = BlockRowSource::get_latest_block_info(&source).await.map_err(BoxError::from)?.ok_or("no tip")?;
	println!("BlockRowSource::get_latest_block_info: {}", pc_block(&tip));
	let n = tip.block_no.0;
	show(
		"BlockRowSource::get_blocks_by_numbers(tip-3, tip)",
		source.get_blocks_by_numbers(BlockNumber(n - 3), BlockNumber(n)).await,
		|rows| rows.iter().map(pc_block).collect(),
	);
	show(
		"BlockRowSource::get_highest_block(tip-10, last hour)",
		source
			.get_highest_block(
				BlockNumber(n - 10),
				tip.time - Duration::hours(1),
				SlotNumber(tip.slot_no.0 - 3600),
				tip.time,
				SlotNumber(tip.slot_no.0),
			)
			.await,
		|row| opt(row, |b| pc_block(&b)),
	);
	show(
		"BlockRowSource::get_block_by_hash(tip)",
		BlockRowSource::get_block_by_hash(&source, McBlockHash(tip.hash)).await,
		|row| opt(row, |b| pc_block(&b)),
	);
	show(
		"BlockRowSource::get_block_by_hash(unknown)",
		BlockRowSource::get_block_by_hash(&source, McBlockHash([0; 32])).await,
		|row| opt(row, |b| pc_block(&b)),
	);
	show(
		"McBlockByHashRowSource::get_block_by_hash(tip)",
		McBlockByHashRowSource::get_block_by_hash(&source, McBlockHash(tip.hash)).await,
		|row| opt(row, |b| mf_block(&b)),
	);
	let tip_mf =
		McBlockByHashRowSource::get_block_by_hash(&source, McBlockHash(tip.hash)).await.map_err(BoxError::from)?.ok_or("tip by hash")?;

	// cNIGHT observation, over the whole index: from the first indexed block to just past the
	// tip, as the node bounds it.
	let first = status.start_block.as_ref().ok_or("no start block")?;
	let start = CardanoPosition {
		block_hash: McBlockHash(first.hash.clone().try_into().map_err(|_| "hash")?),
		block_number: first.block_no,
		block_timestamp: TimestampUnixMillis(first.time_unix_seconds * 1000),
		tx_index_in_block: 0,
	};
	let end = CardanoPosition::from(tip_mf.clone()).increment();
	let query = mf::PagedQuery { start: &start, end: &end, limit: 1000, offset: 0, low_bound: (), high_bound: () };
	let cnight = source.resolve_asset(&unhex(CNIGHT_POLICY), b"").await.map_err(BoxError::from)?.ok_or("cnight")?;
	let auth = source.resolve_asset(&unhex(AUTH_TOKEN_POLICY), b"").await.map_err(BoxError::from)?.ok_or("auth")?;
	println!("CNightObservationRowSource::resolve_asset: {} / {}", h(&cnight.policy_id), h(&auth.policy_id));
	println!(
		"CNightObservationRowSource::get_low_bounds / get_high_bounds: {:?} / {:?}",
		source.get_low_bounds(start.block_number.into()).await.map_err(BoxError::from)?,
		source.get_high_bounds(end.block_number.into()).await.map_err(BoxError::from)?
	);
	show("CNightObservationRowSource::get_max_tx_size(tip)", source.get_max_tx_size(n).await, |s| {
		opt(s, |s| s.to_string())
	});
	show(
		"CNightObservationRowSource::get_registrations",
		source.get_registrations(MAPPING_VALIDATOR, &auth, &query).await,
		|rows| {
			rows.iter()
				.map(|r| {
					format!(
						"{} {} {} tx {} {}#{} datum {}",
						r.block_number.0,
						h(r.block_hash.0),
						time(r.block_timestamp),
						r.tx_index_in_block.0,
						h(r.tx_hash.0),
						r.utxo_index.0,
						datum(r.full_datum.as_ref().map(|d| &d.0))
					)
				})
				.collect()
		},
	);
	show(
		"CNightObservationRowSource::get_deregistrations",
		source.get_deregistrations(MAPPING_VALIDATOR, &query).await,
		|rows| {
			rows.iter()
				.map(|r| {
					format!(
						"{} {} {} tx {} {} spends {}#{} datum {}",
						r.block_number.0,
						h(r.block_hash.0),
						time(r.block_timestamp),
						r.tx_index_in_block.0,
						h(r.tx_hash.0),
						h(r.utxo_tx_hash.0),
						r.utxo_index.0,
						datum(r.full_datum.as_ref().map(|d| &d.0))
					)
				})
				.collect()
		},
	);
	let creates = source.get_asset_creates(&cnight, &query).await;
	let some_tx = creates.as_ref().ok().and_then(|rows| rows.first().map(|r| r.tx_hash.0));
	show("CNightObservationRowSource::get_asset_creates", creates, |rows| {
		rows.iter()
			.map(|r| {
				format!(
					"{} {} {} tx {} {}#{} qty {} at {}",
					r.block_number.0,
					h(r.block_hash.0),
					time(r.block_timestamp),
					r.tx_index_in_block.0,
					h(r.tx_hash.0),
					r.utxo_index.0,
					r.quantity,
					r.holder_address
				)
			})
			.collect()
	});
	show("CNightObservationRowSource::get_asset_spends", source.get_asset_spends(&cnight, &query).await, |rows| {
		rows.iter()
			.map(|r| {
				format!(
					"{} {} {} tx {} {} spends {}#{} qty {} at {}",
					r.block_number.0,
					h(r.block_hash.0),
					time(r.block_timestamp),
					r.tx_index_in_block.0,
					h(r.spending_tx_hash.0),
					h(r.utxo_tx_hash.0),
					r.utxo_index.0,
					r.quantity,
					r.holder_address
				)
			})
			.collect()
	});

	// Federated authority observation
	for (name, (address, policy)) in [("council", COUNCIL), ("technical committee", TECHNICAL_COMMITTEE)] {
		let policy = sidechain_domain::PolicyId(unhex(policy).try_into().map_err(|_| "policy")?);
		show(
			&format!("FederatedAuthorityRowSource::get_governance_body_utxo({name}, tip)"),
			source.get_governance_body_utxo(address, &policy, n).await,
			|row| {
				opt(row, |r| {
					format!(
						"{} {} tx {} {}#{} datum {}",
						r.block_number.0,
						h(r.block_hash.0),
						r.tx_index_in_block.0,
						h(r.tx_hash.0),
						r.utxo_index.0,
						h(r.full_datum.0.to_bytes())
					)
				})
			},
		);
	}

	// Authority selection
	let epoch = EpochNumber(tip.epoch_no.0);
	show(
		"CandidatesRowSource::get_latest_block_for_epoch(tip epoch - 1)",
		source.get_latest_block_for_epoch(EpochNumber(epoch.0 - 1)).await,
		|row| opt(row, |b| cds_block(&b)),
	);
	show(
		"CandidatesRowSource::get_latest_stable_epoch(k)",
		source.get_latest_stable_epoch(K).await,
		|e| opt(e, |e| e.0.to_string()),
	);
	show(
		"CandidatesRowSource::get_stake_distribution(tip epoch)",
		source.get_stake_distribution(epoch).await,
		|rows| rows.iter().map(|r| format!("{} {}", h(r.pool_hash), r.stake.0)).collect(),
	);
	show(
		"CandidatesRowSource::get_token_utxo_for_epoch(permissioned candidates, tip epoch)",
		source
			.get_token_utxo_for_epoch(
				&Asset { policy_id: PolicyId(unhex(PERMISSIONED_CANDIDATES_POLICY)), asset_name: AssetName(vec![]) },
				epoch,
			)
			.await,
		|row| {
			opt(row, |r| {
				format!(
					"{}#{} epoch {} block {} slot {} tx {} datum {}",
					h(r.origin_tx_hash),
					r.utxo_index.0,
					r.tx_epoch_no.0,
					r.tx_block_no.0,
					r.tx_slot_no.0,
					r.tx_block_index.0,
					datum(r.datum.as_ref().map(|d| &d.0))
				)
			})
		},
	);
	for back in (1..=3).rev() {
		show(
			&format!("CandidatesRowSource::get_epoch_nonce(tip epoch - {back})"),
			source.get_epoch_nonce(EpochNumber(epoch.0 - back)).await,
			|row| opt(row, |nonce| h(nonce.0)),
		);
	}
	show("CandidatesRowSource::get_epoch_nonce(tip epoch)", source.get_epoch_nonce(epoch).await, |row| {
		opt(row, |nonce| h(nonce.0))
	});
	show(
		"CandidatesRowSource::get_stake_distribution(tip epoch - 1)",
		source.get_stake_distribution(EpochNumber(epoch.0 - 1)).await,
		|rows| rows.iter().map(|r| format!("{} {}", h(r.pool_hash), r.stake.0)).collect(),
	);
	show(
		"CandidatesRowSource::get_utxos_for_address(committee candidates, tip)",
		source.get_utxos_for_address(&Address(COMMITTEE_CANDIDATES.to_string()), tip.block_no).await,
		|rows| {
			rows.iter()
				.map(|r| {
					format!(
						"{} block {} slot {} epoch {} tx {} at {} datum {} inputs {}",
						utxo(&r.utxo_id),
						r.tx_block_no.0,
						r.tx_slot_no.0,
						r.tx_epoch_no.0,
						r.tx_index_in_block.0,
						r.address,
						datum(r.datum.as_ref()),
						r.tx_inputs.iter().map(utxo).collect::<Vec<_>>().join(",")
					)
				})
				.collect()
		},
	);

	// Bridge
	show(
		"BridgeRowSource::get_bridge_txs(after the start block, up to the tip)",
		source
			.get_bridge_txs(
				&Address(ICS.to_string()),
				&Address(RESERVE.to_string()),
				Asset { policy_id: PolicyId(unhex(CNIGHT_POLICY)), asset_name: AssetName(vec![]) },
				pc::ResolvedBridgeDataCheckpoint::Block { number: BlockNumber(first.block_no - 1) },
				tip.block_no,
				None,
			)
			.await,
		|rows| {
			rows.iter()
				.map(|r| {
					format!(
						"{} tx {} {} metadata {:?} bridge {}/{} reserve {}/{}",
						r.block_number.0,
						r.tx_ix.0,
						h(r.tx_hash.0),
						r.c2m_metadata,
						r.bridge_in.0,
						r.bridge_out.0,
						r.reserve_in.0,
						r.reserve_out.0
					)
				})
				.collect()
		},
	);
	if let Some(tx) = some_tx {
		show(
			&format!("BridgeRowSource::get_block_info_for_tx_hash({})", h(tx)),
			source.get_block_info_for_tx_hash(TxHash(tx)).await,
			|row| opt(row, |p| format!("block {} tx {}", p.block_number.0, p.tx_ix.0)),
		);
	}
	show(
		"BridgeRowSource::get_block_info_for_tx_hash(unknown)",
		source.get_block_info_for_tx_hash(TxHash([0; 32])).await,
		|row| opt(row, |p| format!("block {} tx {}", p.block_number.0, p.tx_ix.0)),
	);

	// Errors the node must not mistake for absent data
	show(
		"error: CandidatesRowSource::get_epoch_nonce(tip epoch + 2)",
		source.get_epoch_nonce(EpochNumber(epoch.0 + 2)).await,
		|row| vec![format!("{:?}", row.map(|n| h(n.0)))],
	);
	show(
		"error: CandidatesRowSource::get_stake_distribution(tip epoch + 3)",
		source.get_stake_distribution(EpochNumber(epoch.0 + 3)).await,
		|rows| vec![format!("{} rows", rows.len())],
	);
	show(
		"error: CandidatesRowSource::get_utxos_for_address(mapping validator: no input lists)",
		source.get_utxos_for_address(&Address(MAPPING_VALIDATOR.to_string()), tip.block_no).await,
		|rows| vec![format!("{} rows", rows.len())],
	);
	show(
		"error: BlockRowSource::get_blocks_by_numbers(tip, tip+1)",
		source.get_blocks_by_numbers(BlockNumber(n), BlockNumber(n + 1)).await,
		|rows| vec![format!("{} rows", rows.len())],
	);
	show(
		"error: FederatedAuthorityRowSource::get_governance_body_utxo(unwatched address)",
		source
			.get_governance_body_utxo(ICS.trim_end_matches('k'), &sidechain_domain::PolicyId([0; 28]), n)
			.await,
		|row| vec![format!("{:?}", row.map(|r| r.block_number.0))],
	);
	Ok(())
}
