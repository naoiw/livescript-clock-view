# LiveScript Clock

LiveScript で時刻・リング描画・パーティクル演出を実装したブラウザ時計です。[CoffeeScript](https://github.com/naoiw/coffee-clock-view)・[Rust](https://github.com/naoiw/rust-clock-view)・[Nim](https://github.com/naoiw/nim-clock-view) 版と同じ見た目・機能を目指し、コード量も比較します。

## 公開先

- 本番: https://naoiw.github.io/livescript-clock-view/
- develop: https://naoiw.github.io/livescript-clock-view/develop/

## ローカル開発

Node.js 26 と npm を用意します。

```bash
npm ci
npm run check
npm run dev
```

`http://localhost:3000/` を開いてください。GitHub Pages は Settings → Pages → Source を **GitHub Actions** に設定してください。

## 仕様

時・分・秒の3リング、日付とデジタル時刻、時刻に応じた色、毎分60粒子のエフェクト、HiDPI・レスポンシブ・reduced-motion 対応、非表示タブで描画停止。

## 構成

- `src/clock.ls`: 時刻計算と Canvas 2D の描画、ブラウザイベント
- `src/styles.css`: 既存時計と共通のCSS
- `tests/`: Node.js標準テスト + ブラウザ動作スモークテスト
- `dist/`: コンパイル生成物（Git管理外）
- `.github/workflows/`: main/develop のCIとPages同時デプロイ
- `docs/architecture.md`: 設計と運用

通常は develop 向けにPRを作り、検証後に develop → main のPRで本番反映します。main と develop の両方を1つの GitHub Pages サイト上の別パスに公開します。

## ライセンス

[MIT](LICENSE)
