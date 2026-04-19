#syntax=docker/dockerfile:1
FROM eclipse-temurin:25-jre-noble as builder
WORKDIR /app/minecraft
COPY --link app /app

RUN apt-get update && apt-get install -y wget
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/v0.0.6/mcrcon" -O /app/control/mcrcon && chmod +x /app/control/mcrcon

# Download mods
## Krypton (TODO: waiting for 26.1.2 support)
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/O9LmWYR7/krypton-0.2.10.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/CsEpiziv/FabricProxy-Lite-2.12.0.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/R7MxYvuW/lithium-fabric-0.24.2%2Bmc26.1.2.jar"
## FerriteCore
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar"
## ScalableLux
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/Ps1zyz6x/versions/gYbHVCz8/ScalableLux-0.2.0%2Bfabric.2b63825-all.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/tnmuHGZA/fabric-api-0.146.1%2B26.1.2.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/l6YH9Als/versions/J1GUYyGQ/spark-1.10.172-fabric.jar"

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
ADD --chmod=644 --checksum=sha256:ce835c0355a8d6102cfa39de08e9ac17ce58e74cd69b73c3743095d34c73bba2 https://github.com/OKTW-Network/Easy-Recipe/releases/download/v1.4.6/Easy-Recipe.zip /app/minecraft/datapacks/
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
