#!/usr/bin/env python3
"""Regenerate data/epoch-nonces/NETWORK.csv from Koios epoch_params.

The table holds, for every Shelley-or-later epoch up to the latest
completed one, the nonce in force during that epoch (db-sync
epoch_param.nonce). Koios is public and needs no key; requests are spaced
out and every response is cached, so a rerun with the same cache directory
does not touch the network.

    scripts/fetch-epoch-nonces.py NETWORK CACHE_DIR > data/epoch-nonces/NETWORK.csv

NETWORK is mainnet, preprod or preview. Delete the cache directory to fetch
fresh data.
"""

import datetime
import json
import os
import sys
import time
import urllib.request

HOSTS = {"mainnet": "api", "preprod": "preprod", "preview": "preview"}
PAGE = 1000
DELAY_SECONDS = 3


def fetch(url, cache_path, headers=None):
    if os.path.exists(cache_path):
        with open(cache_path) as f:
            return json.load(f)
    time.sleep(DELAY_SECONDS)
    request = urllib.request.Request(url, headers=dict(headers or {}, **{"User-Agent": "epoch-nonce-table"}))
    with urllib.request.urlopen(request, timeout=60) as response:
        body = response.read()
    with open(cache_path, "wb") as f:
        f.write(body)
    return json.loads(body)


def main():
    network, cache = sys.argv[1], sys.argv[2]
    host = HOSTS[network]
    base = f"https://{host}.koios.rest/api/v1"
    os.makedirs(cache, exist_ok=True)

    tip_path = os.path.join(cache, f"{host}-tip.json")
    tip = fetch(f"{base}/tip", tip_path)[0]
    retrieved = datetime.datetime.fromtimestamp(os.path.getmtime(tip_path), datetime.timezone.utc)
    last_completed = tip["epoch_no"] - 1

    rows = []
    start = 0
    while True:
        page = fetch(
            f"{base}/epoch_params?select=epoch_no,nonce&order=epoch_no.asc",
            os.path.join(cache, f"{host}-{start}-{start + PAGE - 1}.json"),
            {"Range": f"{start}-{start + PAGE - 1}"},
        )
        rows.extend(page)
        if len(page) < PAGE:
            break
        start += PAGE

    rows = [r for r in rows if r["epoch_no"] <= last_completed]
    epochs = [r["epoch_no"] for r in rows]
    if epochs != list(range(epochs[0], last_completed + 1)):
        sys.exit("epochs are not contiguous")

    print(f"# Epoch nonces of {network}: the nonce in force during each epoch (db-sync epoch_param.nonce).")
    print(f"# Source: {base}/epoch_params, retrieved {retrieved:%Y-%m-%dT%H:%M:%SZ}.")
    print(f"# Epochs {epochs[0]} to {last_completed} (latest completed at retrieval). An empty nonce is the neutral nonce.")
    print("# Regenerate: scripts/fetch-epoch-nonces.py NETWORK CACHE_DIR")
    print("epoch,nonce")
    for r in rows:
        print(f"{r['epoch_no']},{r['nonce'] or ''}")


if __name__ == "__main__":
    main()
