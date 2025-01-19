FROM maven:3.9.5-eclipse-temurin-21 AS build

WORKDIR /graphhopper

# Copy from the subdirectory where we cloned GraphHopper
COPY build/graphhopper .

RUN mvn clean install -DskipTests

FROM eclipse-temurin:21.0.1_12-jre

# Fix ENV syntax
ENV JAVA_OPTS="-Xmx16g -Xms16g"

RUN mkdir -p /data

WORKDIR /graphhopper

# Copy built jar file
COPY --from=build /graphhopper/web/target/graphhopper*.jar ./

COPY graphhopper.sh build/graphhopper/config-example.yml ./

# Enable connections from outside of the container
RUN sed -i '/^ *bind_host/s/^ */&# /p' config-example.yml

VOLUME [ "/data" ]

EXPOSE 8989 8990

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost:8989/health || exit 1

# Split into ENTRYPOINT and CMD for easier parameter override
ENTRYPOINT [ "./graphhopper.sh", "-c", "config-example.yml" ]
CMD ["--url", "https://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf", "--host", "0.0.0.0"]