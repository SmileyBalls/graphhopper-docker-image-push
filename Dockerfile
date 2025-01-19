FROM israelhikingmap/graphhopper

# Expose the port that GraphHopper will run on
EXPOSE 8989

# Set Java options for heap memory
ENV JAVA_OPTS="-Xmx16g -Xms16g"

# Set the default command with the specified parameters
CMD ["--url", "https://download.geofabrik.de/australia-oceania/australia-latest.osm.pbf", "--host", "0.0.0.0"]
