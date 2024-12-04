#syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jre-jammy as builder
WORKDIR /app/minecraft
COPY --link app /app

RUN apt-get update && apt-get install -y wget
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/v0.0.6/mcrcon" -O /app/control/mcrcon && chmod +x /app/control/mcrcon

# Download mods
## Krypton
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/Acz3ttTp/krypton-0.2.8.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/AQhF7kvw/FabricProxy-Lite-2.9.0.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/t1FlWYl9/lithium-fabric-0.14.3%2Bmc1.21.4.jar"
## FerriteCore
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/a3QXXGz2/ferritecore-7.1.0-hotfix-fabric.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/Oh9IKZRD/fabric-api-0.110.5%2B1.21.4.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/l6YH9Als/versions/EOLRjQgC/spark-1.10.120-fabric.jar"

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://meta.fabricmc.net/v2/versions/loader/1.21.4/0.16.9/1.0.1/server/jar" -O fabric-server-launch.jar && \
    java -jar fabric-server-launch.jar --initSettings

FROM eclipse-temurin:21-jre-jammy

# Env setup
ENV PATH="/app/control:${PATH}"

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y libstdc++6 libjemalloc2

# Copy server files
COPY --from=builder --link /app/control /app/control
COPY --from=builder --link --chown=1000 /app/minecraft /app/minecraft

# Download datapack
ADD --chmod=644 --checksum=sha256:46c86d87cdc2a15a78cbf3ac7fb41c7c1b095771072fb1f618bee1225ff78f1d https://github.com/OKTW-Network/Easy-Recipe/releases/download/v1.4.0-snapshot/Easy-Recipe.zip /app/minecraft/datapacks/
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
CMD ["java", "-XX:MaxRAMPercentage=75", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseShenandoahGC", "-XX:ShenandoahGuaranteedGCInterval=30000", "-XX:ShenandoahUncommitDelay=30000", "-jar", "fabric-server-launch.jar"]
