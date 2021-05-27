ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.7.3
ARG MINECRAFT_VERSION=1.16.5

FROM adoptopenjdk/openjdk16:debianslim-jre as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
WORKDIR /app/minecraft
COPY app /app

RUN apt update && apt install wget ca-certificates
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}" -O - | tar xz -C /app/control/ mcrcon

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER}/fabric-installer-${FABRIC_INSTALLER}.jar" && \
    java -jar fabric-installer-${FABRIC_INSTALLER}.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    java -jar fabric-server-launch.jar --nogui --initSettings && \
    rm fabric-installer-${FABRIC_INSTALLER}.jar

# Download mods
## LazyDFU
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.2/lazydfu-0.1.2.jar"
## Krypton
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/fQEb0iXm/versions/0.1.2/krypton-0.1.2.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/8dI2tmqs/versions/v1.1.3/FabricProxy-Lite-1.1.3.jar"
## Starlight
RUN wget --progress=bar:force --content-disposition -P mods "https://github.com/Spottedleaf/Starlight/releases/download/1.0.0-RC2/starlight-forge-1.0.0-RC2-1.16.5.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/gvQqBUqZ/versions/mc1.16.5-0.6.4/lithium-fabric-mc1.16.5-0.6.4.jar"
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/P7dR8mSH/versions/0.34.2+1.16/fabric-api-0.34.2+1.16.jar"
## Spark
RUN wget --progress=bar:force --content-disposition -P mods "https://ci.lucko.me/job/spark/lastSuccessfulBuild/artifact/spark-fabric/build/libs/spark-fabric.jar"
## Hydrogen
#RUN wget --progress=bar:force --content-disposition -P mods "https://cdn.modrinth.com/data/AZomiSrC/versions/mc1.16.5-v0.2.0/hydrogen-fabric-mc1.16.5-0.2.jar"

FROM adoptopenjdk/openjdk16:debianslim-jre
# Env setup
ENV PATH="/app/control:${PATH}"

RUN apt update && apt install ca-certificates

# Copy server files
COPY --from=builder /app/control /app/control
COPY --from=builder --chown=1000 /app/minecraft /app/minecraft

# Copy mods
COPY --chown=1000 mods/* /app/minecraft/mods/

# Run Server
WORKDIR /app/minecraft
USER 1000
EXPOSE 25565
CMD ["java", "-XX:MaxRAMPercentage=80", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseShenandoahGC", "-XX:ShenandoahGuaranteedGCInterval=30000", "-XX:ShenandoahUncommitDelay=5000", "-jar", "fabric-server-launch.jar"]
