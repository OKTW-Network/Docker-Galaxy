ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.6.1.45
ARG MINECRAFT_VERSION=1.16.1

FROM adoptopenjdk/openjdk14:alpine-jre as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
WORKDIR /app/minecraft
COPY app /app

RUN apk add --no-cache wget ca-certificates
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}" -O - | tar xz -C /app/control/ mcrcon

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER}/fabric-installer-${FABRIC_INSTALLER}.jar" && \
    java -jar fabric-installer-${FABRIC_INSTALLER}.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    java -jar fabric-server-launch.jar --nogui --initSettings && \
    rm fabric-installer-${FABRIC_INSTALLER}.jar

# Download mods
## Fabric API
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/3018/319/fabric-api-0.16.2+build.385-1.16.1.jar"
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/2987/321/FabricProxy-1.3.3.jar"
## phosphor
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/2987/621/phosphor-fabric-mc1.16.1-0.6.0+build.7.jar"
## lithium
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/3000/628/lithium-fabric-mc1.16.1-0.5.1.jar"

FROM adoptopenjdk/openjdk14:alpine-jre
# Env setup
ENV PATH="/app/control:${PATH}"

RUN apk add --no-cache ca-certificates

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
