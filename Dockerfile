FROM maven:3.9.5-eclipse-temurin-21 AS build

WORKDIR /graphhopper

# Clone GraphHopper repository
RUN git clone https://github.com/graphhopper/graphhopper.git .

RUN mvn clean install -DskipTests

FROM eclipse-temurin:21.0.1_12-jre

# Install dos2unix to handle line endings
RUN apt-get update && apt-get install -y dos2unix curl

ENV JAVA_OPTS="-Xmx16g -Xms16g"

RUN mkdir -p /data

WORKDIR /graphhopper

# Copy built jar file
COPY --from=build /graphhopper/web/target/graphhopper*.jar ./


# Download config file and shell script, fix line endings
RUN curl -L https://raw.githubusercontent.com/graphhopper/graphhopper/master/config-example.yml -o config-example.yml \
    && curl -L https://raw.githubusercontent.com/graphhopper/graphhopper/master/graphhopper.sh -o graphhopper.sh \
    && dos2unix graphhopper.sh \
    && chmod +x graphhopper.sh

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-example.yml

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

ENTRYPOINT [ "./graphhopper.sh", "-c", "config-example.yml" ]
CMD ["--url", "https://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf", "--host", "0.0.0.0"]