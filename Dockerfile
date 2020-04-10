ARG MCRCON_VERSION=v0.0.6
ARG MCRCON_TAR_FILE=mcrcon-0.0.6-linux-x86-64.tar.gz
ARG FABRIC_INSTALLER=0.5.2.39
ARG MINECRAFT_VERSION=1.15.2

FROM adoptopenjdk/openjdk14-openj9:alpine-jre as builder
ARG MCRCON_VERSION
ARG MCRCON_TAR_FILE
ARG FABRIC_INSTALLER
ARG MINECRAFT_VERSION
WORKDIR /app/minecraft
COPY app /app

RUN apk add --no-cache wget
# Download mcrcon
RUN wget --progress=bar:force "https://github.com/OKTW-Network/mcrcon/releases/download/${MCRCON_VERSION}/${MCRCON_TAR_FILE}" -O - | tar xz -C /app/control/ mcrcon

# Download minecraft server and install fabric
RUN wget --progress=bar:force "https://maven.modmuss50.me/net/fabricmc/fabric-installer/${FABRIC_INSTALLER}/fabric-installer-${FABRIC_INSTALLER}.jar" && \
    java -jar fabric-installer-${FABRIC_INSTALLER}.jar server -mcversion ${MINECRAFT_VERSION} -downloadMinecraft && \
    java -jar fabric-server-launch.jar --nogui --initSettings && \
    rm fabric-installer-${FABRIC_INSTALLER}.jar

# Download mods
## Fabric proxy
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/2845/701/FabricProxy-1.3.0.jar"
## fabric-language-kotlin
RUN wget --progress=bar:force --content-disposition -P mods "https://edge.forgecdn.net/files/2924/213/fabric-language-kotlin-1.3.71+build.1.jar"

FROM adoptopenjdk/openjdk14-openj9:alpine-jre
# Env setup
ENV PATH="/app/control:${PATH}"

# Copy server files
COPY --from=builder /app/control /app/control
COPY --from=builder --chown=1000 /app/minecraft /app/minecraft

# Copy mods
COPY --chown=1000 mods/* /app/minecraft/mods/

# Run Server
WORKDIR /app/minecraft
USER 1000
EXPOSE 25565
CMD ["java", "-XX:MaxRAMPercentage=80", "-Xgc:concurrentScavenge", "-XX:IdleTuningMinIdleWaitTime=30", "-Xaggressive", "-XX:+CompactStrings", "-jar", "fabric-server-launch.jar"]
