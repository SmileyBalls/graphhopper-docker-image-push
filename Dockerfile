FROM israelhikingmap/graphhopper

# Expose the port that GraphHopper will run on
EXPOSE 8989

# Set the default command with the specified parameters
CMD ["--url", "https://download.geofabrik.de/europe/andorra-latest.osm.pbf", "--host", "0.0.0.0"]
