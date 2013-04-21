# NetMap Server

This is the game server behind NetMap.


## Setup

The recommended development environment for the game server code is the
[NetMap server VM](https://github.com/netmap/netmap-server-vm).

### Map Data

If you don't live close to MIT, modify the `bbbike.org` URLs in
[lib/tasks/osm.rake](lib/tasks/osm.rake) to get OpenStreetMap data for your own
neighborhood, then run `rake osm:load`.


## High-Level Structure

The game server is a [Ruby on Rails](http://rubyonrails.org/) application. We
make heavy use of the
[Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
to prepare the HTML, CSS and JavaScript that runs on the client.

The server stores data in a [PostgreSQL](http://www.postgresql.org/) database.
We rely on the geo-spatial indices provided by
[the PostGIS extension](http://postgis.net/).

The game's map overlay is rendered by configuring [mapnik](http://mapnik.org/)
to serve [OpenStreetMap](openstreetmap.org) data.


## Copyright

The NetMap server code is (C) Copyright Massachusetts Institute of Technology
2013, and is made available under the MIT license.
