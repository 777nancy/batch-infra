# サーバーレスバッチ処理

## 概要

コンテナベースのサーバーレスバッチ処理

## AWS サービス

- Batch
  - Fargate
- Step Functions
- EventBridge

## 構成図

![image](architecture.drawio.svg)

## パラメータ

|key|value|
|---|---|
|region|リージョン|
|system|システム名|
|cidr|VPCのcidr|
|public_subnet|-|
|cidr_block|サブネットのcidr block|
|availability_zone|アベイラビリティゾーン|
|batch_schedule_expression|起動設定|