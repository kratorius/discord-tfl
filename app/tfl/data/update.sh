#!/bin/bash

# Updates data for common modes (see `tfl/const.rb`).

wget "https://api.tfl.gov.uk/Line/Mode/bus" -O "bus_lines.json"
wget "https://api.tfl.gov.uk/Line/Mode/national-rail" -O "national_rail_lines.json"
wget "https://api.tfl.gov.uk/Line/Mode/river-bus" -O "river_bus_lines.json"
wget "https://api.tfl.gov.uk/Line/Mode/river-tour" -O "river_tour_lines.json"
