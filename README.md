# 9chan

闇ネットチャットの実装の1つ

sinatra-sseのoriginal:
- https://github.com/radiospiel/sinatra-sse

## Usage

インストール
```
bundle install
```

ビルド
```
cd frontend/9chan
npm install
npm run build
```

設定
```
cp settings.rb.example settings.rb
```

テーブル作成
```
ruby ./models.rb
```

走行
```
rackup
```

## Run on Docker

ビルド
```sh
docker build -t 9chan .
```

設定
```
cp settings.rb.example settings.rb
```
- `DB_NAME` に `/var/9chan/9chan.sqlite3` を指定する

テーブル作成
```
mkdir -p var/9chan
docker run --rm -v $(pwd)/settings.rb:/opt/app/settings.rb -v $(pwd)/var/9chan:/var/9chan 9chan ruby ./models.rb
```

走行
```
docker run --rm -it -v $(pwd)/settings.rb:/opt/app/settings.rb -v $(pwd)/var/9chan:/var/9chan -p 127.0.0.1:9292:9292 9chan
```

## Run on Docker (arm/v7)

ビルド
```sh
docker build --platform linux/arm/v7 -t 9chan:latest-armv7 .
```

設定
```
cp settings.rb.example settings.rb
```
- `DB_NAME` に `/var/9chan/9chan.sqlite3` を指定する

テーブル作成
```
mkdir -p var/9chan
docker run --rm -v $(pwd)/settings.rb:/opt/app/settings.rb -v $(pwd)/var/9chan:/var/9chan 9chan:latest-armv7 ruby ./models.rb
```

走行
```
docker run --rm -it -v $(pwd)/settings.rb:/opt/app/settings.rb -v $(pwd)/var/9chan:/var/9chan -p 127.0.0.1:9292:9292 9chan:latest-armv7
```

リモートで走行（デバッグ実行）
```
target_host=<<sshで指定可能なホスト名>>
ssh "${target_host}" 'sudo mkdir -p /var/9chan'
cat settings.rb | ssh "${target_host}" 'tee /tmp/9chan/settings.rb > /dev/null'
docker image save 9chan:latest-armv7 | gzip -9c | ssh "${target_host}" 'gunzip -c | docker image load'
ssh -t "${target_host}" 'docker run --rm -it -v /tmp/9chan/settings.rb:/opt/app/settings.rb -v /var/9chan:/var/9chan -p 127.0.0.1:9292:9292 9chan:latest-armv7
```
