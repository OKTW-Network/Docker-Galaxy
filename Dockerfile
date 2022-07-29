#syntax=docker/dockerfile:1
ARG FABRIC_INSTALLER=0.11.0
ARG MINECRAFT_VERSION=1.19.1

FROM eclipse-temurin:17-jre-alpine as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
WORKDIR /app/minecraft
COPY --link app /app

RUN apk add --no-cache wget ca-certificates
# Download mcrcon
RUN wget --progress=bar:force "https://cdn.discordapp.com/attachments/439314137584107532/995321360425418852/mcrcon" -O /app/control/mcrcon && chmod +x /app/control/mcrcon

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER}/fabric-installer-${FABRIC_INSTALLER}.jar" && \
    java -jar fabric-installer-${FABRIC_INSTALLER}.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    java -jar fabric-server-launch.jar --nogui --initSettings && \
    rm fabric-installer-${FABRIC_INSTALLER}.jar

# Download mods
## LazyDFU
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar"
## Krypton
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/361495932971515904/1002558405296275526/krypton-0.2.1-SNAPSHOT.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/v2.2.0/FabricProxy-Lite-2.2.0.jar"
## Starlight
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.1+1.19/starlight-1.1.1%2Bfabric.ae22326.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.discordapp.com/attachments/361495932971515904/1002454567943933952/lithium-fabric-mc1.19.1-0.8.2-SNAPSHOT.jar"
## FerriteCore
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/uXXizFIs/versions/5.0.0-fabric/ferritecore-5.0.0-fabric.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.58.5+1.19.1/fabric-api-0.58.5%2B1.19.1.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://ci.lucko.me/job/spark/328/artifact/spark-fabric/build/libs/spark-1.9.29-fabric.jar"

FROM eclipse-temurin:17-jre-alpine

# Env setup
ENV PATH="/app/control:${PATH}"

RUN apk upgrade --no-cache
RUN apk add --no-cache bash ca-certificates

# Copy server files
COPY --from=builder --link /app/control /app/control
COPY --from=builder --link --chown=1000 /app/minecraft /app/minecraft

# Copy mods
COPY --link --chown=1000 mods/* /app/minecraft/mods/

# Run Server
WORKDIR /app/minecraft
USER 1000
EXPOSE 25565
CMD ["java", "-XX:MaxRAMPercentage=75", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseShenandoahGC", "-XX:ShenandoahGuaranteedGCInterval=30000", "-XX:ShenandoahUncommitDelay=30000", "-XX:ShenandoahGCMode=iu", "-jar", "fabric-server-launch.jar"]
