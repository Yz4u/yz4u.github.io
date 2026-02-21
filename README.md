# yz4u-tweaks

Sileo/APT repository staging for the Yz4u JB Comfort Project.

## Purpose (EN / JA)
`LockAlive` is a jailbreak tweak that keeps SSH/Wi-Fi reachable while your iPhone is locked.
It is designed for users who run SSH, file transfer, or remote commands during lock state and want fewer disconnects.

`LockAlive` は、iPhoneロック中でも SSH/Wi-Fi の接続を維持しやすくする JB 向け tweak です。
ロック中に SSH・ファイル転送・リモート操作を使う人向けに、接続切れを減らすことを目的としています。

## Current Package
- `debs/com.yz4u.lockalive_1.0.0_iphoneos-arm64.deb`

## Tested Environment (EN / JA)
- Tested on: iPhone 14 Plus (`iPhone14,8`), iOS `16.3.1 (20D67)`, rootless jailbreak + ElleKit
- Verification: SpringBoard injection confirmed, 2-minute lock soak test passed (`22: 12/12`, `2222: 12/12`)
- Baseline comparison device: iPhone 13 Pro, iOS `16.3 (20D47)`

- テスト環境: iPhone 14 Plus（`iPhone14,8`）, iOS `16.3.1 (20D67)`、rootless jailbreak + ElleKit
- 検証結果: SpringBoard への注入確認済み、2分ロックsoakテスト合格（`22: 12/12`, `2222: 12/12`）
- 比較用ベースライン端末: iPhone 13 Pro, iOS `16.3 (20D47)`

## Regenerate Repo Indexes
Run after adding/updating `.deb` files:

```bash
cd yz4u-tweaks
./scripts/generate_repo_indexes.sh
```

This regenerates:
- `Packages`
- `Packages.gz`
- `Release`

## Expected GitHub Pages URL
- `https://yz4u.github.io/`

## Sileo Source URL
- `https://yz4u.github.io/`
