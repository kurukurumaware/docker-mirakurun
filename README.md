
# Docker上にMirakurunを構築

## コンテナの起動準備

### ホストPCにディレクトリを作成

/etc/mirakurun/config/  
Mirakurunの設定ファイルを置く

/var/lib/mirakurun/  
MirakurunのEPGデータが保存される

### 起動に必要なファイルの配置

ホストPCに次のファイルを配置する  

```none
/etc/mirakurun/config/server.yml
/etc/mirakurun/config/tuners.yml
/etc/mirakurun/config/channels.yml
/etc/mirakurun/config/start.sh
```

server.yml,tuners.yml,channels.ymlはそれぞれmirakurunの設定を探して読み作成する。これらのファイルを配置せずに起動した場合はデフォルト設定値で３つのファイルが作成される。

start.shは**通常無しで良い**。Mirakurun起動前に実行したいスクリプトがあれば作成し、chmod +x で実行権限を付けて配置する。 例としてログレベルを変更したい場合や、内部のライブラリを別のものと置き換えたい場合に以下のように作成する

```shell
#!/bin/sh

echo Mirakurunの起動前にスクリプトを実行します

# ログレベルを変更したい場合
export LOG_LEVEL=${LOG_LEVEL:-"2"}

# 置き換えたいライブラリ等あれば、ホスト上のstart.shと
# 同じディレクトリにライブラリファイルを配置する
if [ -e "/app-config/libpcsclite.so.1.0.0" ]; then
  cp /app-config/libpcsclite.so.1.0.0 /usr/lib/
fi

```

&nbsp;

## コンテナの起動

### docker run による起動

```shell
docker run -it  --rm \
    --name mirackurun \
    -v /var/run:/var/run \
    -v /etc/mirakurun/config/:/app-config/ \
    -v /var/lib/mirakurun/:/app-data/ \
    --cap-add SYS_ADMIN \
    --cap-add SYS_NICE \
    -p 40772:40772 \
    -p 9229:9229 \
    --device=/dev/px4video0:/dev/video0 \
    --device=/dev/px4video1:/dev/video1 \
    --device=/dev/px4video2:/dev/video2 \
    --device=/dev/px4video3:/dev/video3 \
    kurukurumaware/mirakurun
```

### docker-compose.yml を作成して起動

```shell
version: "3.7"
services:
  mirakurun:
    image: kurukurumaware/mirakurun:latest
    container_name: mirakurun
    cap_add:
      - SYS_ADMIN
      - SYS_NICE
    environment:
      TZ: Asia/Tokyo
      # LOG_LEVEL: "3"
      # DEBUG: "true"
    ports:
      - 40772:40772
      - 9229:9229
    devices:
      - /dev/px4video0:/dev/video0
      - /dev/px4video1:/dev/video1
      - /dev/px4video2:/dev/video2
      - /dev/px4video3:/dev/video3
    volumes:
      - /var/run/:/var/run/
      - /etc/mirakurun/config/:/app-config/
      - /var/lib/mirakurun/:/app-data/
    restart: always

```

起動  
docker-compose up

停止  
docker-compose stop  

&nbsp;

---

## 動作確認環境

px-w3u4  
Intel Pentium J3710  
Debian GNU/Linux 10 Linux 4.19.0-9-amd64  
