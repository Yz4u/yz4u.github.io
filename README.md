# yz4u.github.io APT Source

A clean APT repository for Yz4u jailbreak tweaks and experiments.

## Repository Scope
This README describes the repository itself.
Individual tweak details are listed under "Available Tweaks."

## Sileo Source URL
- `https://yz4u.github.io/`

## Available Tweaks
1. LockAlive
- Package ID: `com.yz4u.lockalive`
- Latest published version: `1.0.6`
- Summary: Keeps SSH/Wi-Fi reachable while the device is locked to reduce disconnects during SSH, file transfer, and remote command workflows.
- Runtime: rootless jailbreak + ElleKit

## Tested Environment
- iPhone 14 Plus (`iPhone14,8`), iOS `16.3.1 (20D67)`, rootless jailbreak + ElleKit
- Verification: SpringBoard injection confirmed; 2-minute lock soak test passed (`22: 12/12`, `2222: 12/12`)
- Baseline comparison: iPhone 13 Pro, iOS `16.3 (20D47)`

## Regenerate APT Indexes
Run after adding or updating `.deb` files:

```bash
./scripts/generate_repo_indexes.sh
```

This regenerates:
- `Packages`
- `Packages.gz`
- `Release`

## Repository Layout
- `debs/`: package artifacts
- `Packages`, `Packages.gz`, `Release`: APT metadata
- `scripts/generate_repo_indexes.sh`: metadata generator
