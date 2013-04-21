# NetMap Server

This is the game server behind NetMap.


## Setup

The recommended method of developing on the game server code is to
[set up a server development VM](doc/vm-server-use.md).

If you would like to deploy your fork of the game server into production,
you might be able to reuse
[the development VM build steps](doc/vm-server-build.md). You will most likely
fork [the VM setup script](doc/vm-server-update.sh).

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
