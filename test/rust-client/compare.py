"""Recompute, straight from the SQLite index, what the Rust client check prints, and diff.

Usage: python3 -I compare.py DB RUST_OUTPUT (the database the server serves, preview)
The SQL below is written from the db-sync queries' semantics (CONTRACT.md / proto comments),
independently of McFollower.Query.
"""
import sqlite3, sys, datetime, os

db, out = sys.argv[1], sys.argv[2]
c = sqlite3.connect(f"file:{db}?immutable=1", uri=True)
q = lambda sql, *a: c.execute(sql, a).fetchall()
hx = lambda b: b.hex()
t = lambda s: datetime.datetime.fromtimestamp(s, datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S") + ".000"
u64 = lambda n: n & 0xFFFFFFFFFFFFFFFF

CNIGHT = bytes.fromhex("d2dbff622e509dda256fedbd31ef6e9fd98ed49ad91d5c0e07f68af1")
AUTH = bytes.fromhex("7e69087d98fac5869eac14e13dfb6f98228c41e638aa2a59d1f85e9c")
MAP = "addr_test1wplxjzranravtp574s2wz00md7vz9rzpucu252je68u9a8qzjheng"
COUNCIL = ("addr_test1wzy47zdsq22pg9l48c5v0f835ljdjzkz47sa5za9cehcejcw28k2d", bytes.fromhex("895f09b002941417f53e28c7a4f1a7e4d90ac2afa1da0ba5c66f8ccb"))
TC = ("addr_test1wptcy7h9rmkhdnhn3jvm6tuhehcq2hhhzntvn00nq79ph8c44v43j", bytes.fromhex("57827ae51eed76cef38c99bd2f97cdf0055ef714d6c9bdf3078a1b9f"))
PERM = bytes.fromhex("24dccfce2576ae6fa7149bc485850656ae6faf9f4158891316773a78")
K = 432

exp = {}
def section(name, lines): exp[name] = lines
ERROR = "ERROR"  # the call must fail (UNAVAILABLE): the indexer does not know the value

# Epoch data (CONTRACT.md S13, S14 and the serving rules in README): nonces from the
# shipped table up to its last epoch, then the nonce driver's; stake only when complete;
# maxTxSize from a node's row, else preview's table (16384 from epoch 0) unless an
# unacknowledged proposal could have changed it.
table = {}
for line in open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../data/epoch-nonces/preview.csv")):
    line = line.strip()
    if line and not line.startswith("#") and line != "epoch,nonce":
        e, n = line.split(",")
        table[int(e)] = n
def nonce(e):
    if e in table: return [table[e]] if table[e] else []
    r = q("select nonce from epoch_nonce where epoch_no = ?", e)
    if not r: return ERROR
    return [hx(r[0][0])] if r[0][0] is not None else []
def stake(e):
    if not q("select 1 from epoch_stake where epoch_no = ? and complete = 1", e): return ERROR
    return [f"{hx(r[0])} {u64(r[1])}" for r in q("select pool_hash, stake from pool_stake where epoch_no = ? order by pool_hash", e)]
def max_tx_size(e):
    r = q("select max_tx_size from epoch_param where epoch_no = ?", e)
    if r: return [str(r[0][0])]
    if q("select 1 from max_tx_size_sighting where earliest_epoch <= ?", e): return ERROR
    return ["16384"]

(tip_no, tip_hash, tip_epoch, tip_slot, tip_time, tip_txs), = q("select block_no, hash, epoch_no, slot_no, time, tx_count from block where block_no is not null order by block_no desc limit 1")
blk = lambda r: f"block {r[0]} {hx(r[1])} epoch {r[2]} slot {r[3]} time {t(r[4])}"
blocks = lambda sql, *a: [blk(r) for r in q("select block_no, hash, epoch_no, slot_no, time from block " + sql, *a)]
section("BlockRowSource::get_blocks_by_numbers(tip-3, tip)", blocks("where block_no between ? and ? order by block_no", tip_no - 3, tip_no))
section("BlockRowSource::get_highest_block(tip-10, last hour)", blocks(
    "where block_no <= ? and slot_no between ? and ? and time between ? and ? order by block_no desc limit 1",
    tip_no - 10, tip_slot - 3600, tip_slot, tip_time - 3600, tip_time))
section("BlockRowSource::get_block_by_hash(tip)", blocks("where hash = ?", tip_hash))
section("BlockRowSource::get_block_by_hash(unknown)", [])
section("McBlockByHashRowSource::get_block_by_hash(tip)", [blocks("where hash = ?", tip_hash)[0] + f" txs {tip_txs}"])
section("CNightObservationRowSource::get_max_tx_size(tip)", max_tx_size(tip_epoch))

first, = q("select min(block_no) from block where block_no is not null")[0]
win = (first, 0, tip_no, tip_txs + 1)
inwin = lambda b, i: (first, 0) <= (b, i) < (tip_no, tip_txs + 1)

regs = q("""select o.block_no, b.hash, b.time, o.block_index, o.tx_hash, o.idx, d.bytes
  from tx_out o join datum d on d.hash = o.datum_hash join block b on b.id = o.block_id
  where o.address = ? and exists (select 1 from ma_tx_out m where m.tx_out_id = o.id and m.policy = ? and m.name = x'' and m.quantity = 1)
  order by o.block_no, o.block_index, o.idx""", MAP, AUTH)
section("CNightObservationRowSource::get_registrations", [
    f"{r[0]} {hx(r[1])} {t(r[2])} tx {r[3]} {hx(r[4])}#{r[5]} datum {hx(r[6])}" for r in regs if inwin(r[0], r[3])][:1000])
deregs = q("""select s.block_no, s.hash, s.time, o.spent_block_index, tx.hash, o.tx_hash, o.idx, d.bytes
  from tx_out o join datum d on d.hash = o.datum_hash join block s on s.id = o.spent_block_id
  join tx on tx.block_id = o.spent_block_id and tx.block_index = o.spent_block_index
  where o.address = ? order by s.block_no, o.spent_block_index, o.tx_hash, o.idx""", MAP)
section("CNightObservationRowSource::get_deregistrations", [
    f"{r[0]} {hx(r[1])} {t(r[2])} tx {r[3]} {hx(r[4])} spends {hx(r[5])}#{r[6]} datum {hx(r[7])}" for r in deregs if inwin(r[0], r[3])][:1000])
creates = q("""select b.block_no, b.hash, b.time, o.block_index, o.tx_hash, o.idx, m.quantity, o.address
  from ma_tx_out m join tx_out o on o.id = m.tx_out_id join block b on b.id = o.block_id
  where m.policy = ? and m.name = x'' order by b.block_no, o.block_index, o.idx""", CNIGHT)
section("CNightObservationRowSource::get_asset_creates", [
    f"{r[0]} {hx(r[1])} {t(r[2])} tx {r[3]} {hx(r[4])}#{r[5]} qty {u64(r[6])} at {r[7]}" for r in creates if inwin(r[0], r[3])][:1000])
spends = q("""select s.block_no, s.hash, s.time, o.spent_block_index, tx.hash, o.tx_hash, o.idx, m.quantity, o.address
  from ma_tx_out m join tx_out o on o.id = m.tx_out_id join block s on s.id = o.spent_block_id
  join tx on tx.block_id = o.spent_block_id and tx.block_index = o.spent_block_index
  where m.policy = ? and m.name = x'' order by s.block_no, o.spent_block_index, o.tx_hash, o.idx""", CNIGHT)
section("CNightObservationRowSource::get_asset_spends", [
    f"{r[0]} {hx(r[1])} {t(r[2])} tx {r[3]} {hx(r[4])} spends {hx(r[5])}#{r[6]} qty {u64(r[7])} at {r[8]}" for r in spends if inwin(r[0], r[3])][:1000])

for name, (addr, pol) in [("council", COUNCIL), ("technical committee", TC)]:
    rows = q("""select o.block_no, b.hash, o.block_index, o.tx_hash, o.idx, d.bytes
      from tx_out o join datum d on d.hash = o.datum_hash join block b on b.id = o.block_id
      where o.address = ? and o.block_no <= ? and exists (select 1 from ma_tx_out m where m.tx_out_id = o.id and m.policy = ?)
      order by o.block_no desc, o.block_index desc, o.idx desc limit 1""", addr, tip_no, pol)
    section(f"FederatedAuthorityRowSource::get_governance_body_utxo({name}, tip)", [
        f"{r[0]} {hx(r[1])} tx {r[2]} {hx(r[3])}#{r[4]} datum {hx(r[5])}" for r in rows])

section("CandidatesRowSource::get_latest_block_for_epoch(tip epoch - 1)", [
    f"block {r[0]} {hx(r[1])} epoch {r[2]} slot {r[3]}" for r in q(
        "select block_no, hash, epoch_no, slot_no from block where epoch_no <= ? and block_no is not null order by slot_no desc limit 1", tip_epoch - 1)])
section("CandidatesRowSource::get_latest_stable_epoch(k)", [str(r[0]) for r in q(
    "select s.epoch_no - 1 from block b join block s on s.block_no = b.block_no - ? where b.block_no is not null order by b.block_no desc limit 1", K)])
section("CandidatesRowSource::get_stake_distribution(tip epoch)", stake(tip_epoch))
section("CandidatesRowSource::get_stake_distribution(tip epoch - 1)", stake(tip_epoch - 1))
tok = q("""select o.tx_hash, o.idx, b.epoch_no, b.block_no, b.slot_no, o.block_index, d.bytes
  from ma_tx_out m join tx_out o on o.id = m.tx_out_id join block b on b.id = o.block_id left join datum d on d.hash = o.datum_hash
  where m.policy = ? and m.name = x'' and b.epoch_no <= ? order by b.block_no desc, o.block_index desc, o.idx desc limit 1""", PERM, tip_epoch)
section("CandidatesRowSource::get_token_utxo_for_epoch(permissioned candidates, tip epoch)", [
    f"{hx(r[0])}#{r[1]} epoch {r[2]} block {r[3]} slot {r[4]} tx {r[5]} datum {hx(r[6]) if r[6] else '-'}" for r in tok])
for back in (3, 2, 1):
    section(f"CandidatesRowSource::get_epoch_nonce(tip epoch - {back})", nonce(tip_epoch - back))
section("CandidatesRowSource::get_epoch_nonce(tip epoch)", nonce(tip_epoch))
section("error: CandidatesRowSource::get_epoch_nonce(tip epoch + 2)", nonce(tip_epoch + 2))
section("error: CandidatesRowSource::get_stake_distribution(tip epoch + 3)", stake(tip_epoch + 3))
CAND = "addr_test1wz5ax0hjvhx2uqef8sqrxnmfywd37hea4truhqxu4yxp9hsvggkfm"
cand = []
for r in q("""select o.tx_hash, o.idx, o.block_no, b.slot_no, b.epoch_no, o.block_index, o.address, d.bytes, o.block_id
    from tx_out o join block b on b.id = o.block_id left join datum d on d.hash = o.datum_hash
    where o.address = ? and o.block_no <= ? and (o.spent_block_no is null or o.spent_block_no > ?)
    order by o.block_no, o.block_index, o.idx""", CAND, tip_no, tip_no):
    ins = ",".join(f"{hx(i[0])}#{i[1]}" for i in q("select tx_hash, idx from tx_input where block_id = ? and block_index = ? order by tx_hash, idx", r[8], r[5]))
    cand.append(f"{hx(r[0])}#{r[1]} block {r[2]} slot {r[3]} epoch {r[4]} tx {r[5]} at {r[6]} datum {hx(r[7]) if r[7] else '-'} inputs {ins}")
section("CandidatesRowSource::get_utxos_for_address(committee candidates, tip)", cand)

# Bridge: candidate txs creating an ICS output with the token, after the start block, up to the tip.
ICS = "addr_test1wzga9g4tw69twfvpjynyvdyzvpf5f0e88v6hnu9eh9qgdnqaw66xk"
RES = "addr_test1wzdpdpyev08npr3ktyy9dskvh2v9wk3vphamd6kk60qmjtgftyu2n"
def total(sql, *a): return sum(u64(r[0]) for r in q(sql, *a))
lines = []
for bid, bno, ix, h in q("""select distinct o.block_id, o.block_no, o.block_index, tx.hash from tx_out o join ma_tx_out m on m.tx_out_id = o.id
    join tx on tx.block_id = o.block_id and tx.block_index = o.block_index
    where o.address = ? and m.policy = ? and m.name = x'' and o.block_no > ? and o.block_no <= ? order by o.block_no, o.block_index""", ICS, CNIGHT, first - 1, tip_no):
    created = lambda a: total("select m.quantity from tx_out o join ma_tx_out m on m.tx_out_id = o.id where o.address = ? and o.block_id = ? and o.block_index = ? and m.policy = ? and m.name = x''", a, bid, ix, CNIGHT)
    consumed = lambda a: total("select m.quantity from tx_out o join ma_tx_out m on m.tx_out_id = o.id where o.address = ? and o.spent_block_id = ? and o.spent_block_index = ? and m.policy = ? and m.name = x''", a, bid, ix, CNIGHT)
    bi, bo, ri, ro = consumed(ICS), created(ICS), consumed(RES), created(RES)
    if bo > bi or ri > ro:
        md = q("select cbor from tx_metadata where block_id = ? and block_index = ? and label = 6500973", bid, ix)
        lines.append(f"{bno} tx {ix} {hx(h)} metadata {('Some(Array [String(\"0x' + md[0][0][2:].hex() + '\")])') if md and md[0][0][:2] == bytes([0x81, 0x44]) else ('?' if md else 'None')} bridge {bi}/{bo} reserve {ri}/{ro}")
section("BridgeRowSource::get_bridge_txs(after the start block, up to the tip)", lines)
for (h,) in q("select o.tx_hash from ma_tx_out m join tx_out o on o.id = m.tx_out_id join block b on b.id = o.block_id where m.policy = ? and m.name = x'' order by b.block_no, o.block_index, o.idx limit 1", CNIGHT):
    section(f"BridgeRowSource::get_block_info_for_tx_hash({hx(h)})", [f"block {r[0]} tx {r[1]}" for r in q("select b.block_no, t.block_index from tx t join block b on b.id = t.block_id where t.hash = ?", h)])
section("BridgeRowSource::get_block_info_for_tx_hash(unknown)", [])

# Parse the Rust output into sections.
got, cur = {}, None
for line in open(out):
    line = line.rstrip("\n")
    if line.startswith("  ") and cur is not None:
        got[cur].append(line[2:])
    elif ": " in line and " row(s)" in line:
        cur = line.split(": ")[0]
        got[cur] = []
    elif ": error: " in line:
        got[line.split(": error: ")[0]] = ERROR
        print(f"         ({line[:200]})")
        cur = None
    else:
        cur = None

ok = True
for name, lines in exp.items():
    g = got.get(name)
    if g is None:
        print(f"MISSING  {name}"); ok = False; continue
    # Rust prints datums re-encoded by CSL; compare them separately.
    if g == lines:
        print(f"MATCH    {name} ({'an error' if lines == ERROR else str(len(lines)) + ' rows'})")
    else:
        ok = False
        print(f"DIFFER   {name}: rust {g if g == ERROR else len(g)} rows, sqlite {lines if lines == ERROR else len(lines)} rows")
        for a, b in zip(g, lines):
            if a != b:
                print(f"   rust:   {a}\n   sqlite: {b}")
                break
print("ALL MATCH" if ok else "SOME DIFFER")
