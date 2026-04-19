#syntax=docker/dockerfile:1
FROM eclipse-temurin:25-jre-noble as builder
WORKDIR /app/minecraft
COPY --link app /app

RUN apt-get update && apt-get install -y wget

# Download mcrcon
# SHA512: e25f39c33b090f2b643f8299816069eee0f0938ccc52ac0e21d489c25c7c059ffbf0e9268c0a9f867e4aa2a05a28854c6c50872bbc5a6cf452f3724c0a0ac7a5
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/v0.0.6/mcrcon" -O /tmp/mcrcon && \
    echo "e25f39c33b090f2b643f8299816069eee0f0938ccc52ac0e21d489c25c7c059ffbf0e9268c0a9f867e4aa2a05a28854c6c50872bbc5a6cf452f3724c0a0ac7a5 /tmp/mcrcon" | sha512sum -c - && \
    mv /tmp/mcrcon /app/control/mcrcon && \
    chmod +x /app/control/mcrcon

# Download mods
## Krypton (TODO: waiting for 26.1.2 support)
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/O9LmWYR7/krypton-0.2.10.jar"

## Fabric proxy
# SHA512: b479c3ed1fe83929cad40e5c925ae2702da879b88a0271a24266cd21ecc037953f347cbe61ac7b7334e087544ee2ce5bf1f041fc3e64f50474404ad564c146f7
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/CsEpiziv/FabricProxy-Lite-2.12.0.jar" && \
    echo "b479c3ed1fe83929cad40e5c925ae2702da879b88a0271a24266cd21ecc037953f347cbe61ac7b7334e087544ee2ce5bf1f041fc3e64f50474404ad564c146f7 mods/FabricProxy-Lite-2.12.0.jar" | sha512sum -c -

## lithium
# SHA512: 9231ad05667d4eef0348c700bf5160929e0b723d9e145fd97c7fcef9387ac2e6d524fb15d99f47f8f838f1d235324fd750cdcb6603b63aab6085d79fbeaab31b
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/R7MxYvuW/lithium-fabric-0.24.2%2Bmc26.1.2.jar" && \
    echo "9231ad05667d4eef0348c700bf5160929e0b723d9e145fd97c7fcef9387ac2e6d524fb15d99f47f8f838f1d235324fd750cdcb6603b63aab6085d79fbeaab31b mods/lithium-fabric-0.24.2+mc26.1.2.jar" | sha512sum -c -

## FerriteCore
# SHA512: d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar" && \
    echo "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584 mods/ferritecore-9.0.0-fabric.jar" | sha512sum -c -

## ScalableLux
# SHA512: 48565a4d8a1cbd623f0044086d971f2c0cf1c40e1d0b6636a61d41512f4c1c1ddff35879d9dba24b088a670ee254e2d5842d13a30b6d76df23706fa94ea4a58b
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/Ps1zyz6x/versions/gYbHVCz8/ScalableLux-0.2.0%2Bfabric.2b63825-all.jar" && \
    echo "48565a4d8a1cbd623f0044086d971f2c0cf1c40e1d0b6636a61d41512f4c1c1ddff35879d9dba24b088a670ee254e2d5842d13a30b6d76df23706fa94ea4a58b mods/ScalableLux-0.2.0+fabric.2b63825-all.jar" | sha512sum -c -

## Fabric API
# SHA512: cd8a760ecb976127036f8047c1e968f264aea9cd9deca60e6e9cb57496b1b5cca79873c59b7ab46b92f49ac22f49a2b695bb6ebe61653c8df6954e97b8836890
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/tnmuHGZA/fabric-api-0.146.1%2B26.1.2.jar" && \
    echo "cd8a760ecb976127036f8047c1e968f264aea9cd9deca60e6e9cb57496b1b5cca79873c59b7ab46b92f49ac22f49a2b695bb6ebe61653c8df6954e97b8836890 mods/fabric-api-0.146.1+26.1.2.jar" | sha512sum -c -

## Spark
# SHA512: e0697663689c5459b7ed92f21d86b0191bbe7f6327ac7e8972ad9f6318ef7a8ca93da3a8495459ee6f1443cadff7656b150ea0efc81f8cf1300c9301483a2fb3
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/l6YH9Als/versions/J1GUYyGQ/spark-1.10.172-fabric.jar" && \
    echo "e0697663689c5459b7ed92f21d86b0191bbe7f6327ac7e8972ad9f6318ef7a8ca93da3a8495459ee6f1443cadff7656b150ea0efc81f8cf1300c9301483a2fb3 mods/spark-1.10.172-fabric.jar" | sha512sum -c -

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://meta.fabricmc.net/v2/versions/loader/26.1.2/0.19.2/1.1.1/server/jar" -O fabric-server-launch.jar && \
    java -jar fabric-server-launch.jar --initSettings

FROM eclipse-temurin:25-jre-noble

# Env setup
ENV PATH="/app/control:${PATH}"

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y libstdc++6 libjemalloc2

# Copy server files
COPY --from=builder --link /app/control /app/control
COPY --from=builder --link --chown=1000 /app/minecraft /app/minecraft

# Download datapack
ADD --chmod=644 --checksum=sha256:8bb14855265f38ec398619db854994ecd5bfade9f42d2b189ccf2c6097e7daba https://github.com/OKTW-Network/Easy-Recipe/releases/download/v1.4.7/Easy-Recipe.zip /app/minecraft/datapacks/
# Copy config
COPY --link --chown=1000 config /app/minecraft/config
# Copy mods
COPY --link --chown=1000 mods/* /app/minecraft/mods/

# Run Server
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libjemalloc.so.2"
ENV MALLOC_CONF="background_thread:true"
WORKDIR /app/minecraft
USER 1000
EXPOSE 25565
CMD ["java", "-XX:MaxRAMPercentage=75", "-XX:+UseZGC", "-XX:+ZGenerational", "-XX:ZUncommitDelay=30", "-XX:ZCollectionIntervalMinor=30", "-XX:ZCollectionIntervalMajor=300", "-jar", "fabric-server-launch.jar"]
