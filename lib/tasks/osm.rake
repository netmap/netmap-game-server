require 'etc'


directory 'vendor/osm'

# If you don't develop in Cambridge, get your own map.osm.pbf from
#     http://download.bbbike.org/osm/

file 'vendor/osm/map.osm.pbf' => 'vendor/osm' do
  url = 'http://download.bbbike.org/osm/bbbike/CambridgeMa/CambridgeMa.osm.pbf'
  Kernel.system "curl --fail --output vendor/osm/map.osm.pbf #{url}"
end

file 'vendor/osm/map.osm.gz' => 'vendor/osm' do
  url = 'http://download.bbbike.org/osm/bbbike/CambridgeMa/CambridgeMa.osm.gz'
  Kernel.system "curl --fail --output vendor/osm/map.osm.gz #{url}"
end
file 'vendor/osm/map.osm' => 'vendor/osm/map.osm.gz' do
  Kernel.system 'gunzip vendor/osm/map.osm.gz'
end

namespace :osm do
  task :create do
    Kernel.system 'createdb --encoding=UTF8 netmap-gis'
    Kernel.system 'psql netmap-gis --quiet ' +
                  '--command="CREATE EXTENSION hstore;"'
    Kernel.system 'psql netmap-gis --quiet ' +
                  '--command="CREATE EXTENSION postgis SCHEMA public;"'
  end
  task :drop do
    Kernel.system 'dropdb netmap-gis'
  end
  task :load => 'vendor/osm/map.osm' do
    Kernel.system 'osm2pgsql --create --database=netmap-gis --slim --hstore ' +
        '--output=pgsql vendor/osm/map.osm'
    #Kernel.system 'osmosis --read-pbf vendor/osm/map.osm.pbf ' +
    #    "--write-pgsql database=netmap-gis"
  end
end
