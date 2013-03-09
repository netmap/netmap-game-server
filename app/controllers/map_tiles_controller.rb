class MapTilesController < ApplicationController
  # GET /map
  def index

  end

  # GET /map_tiles/zoom/x/y.png
  def show
    map = self.class.map
    tile = Mapnik::Tile.new params[:zoom], params[:x], params[:y]

    render text: tile.render_to_string(map), content_type: 'image/png',
           disposition: 'inline'
  end

  # The per-process cached Mapnik::Map instance.
  #
  # @return {Mapnik::Map} map set up for rendering the game world
  def self.map
    @map ||= map!
  end

  # Creates a Mapnik::Map appropriately styled to render the game world.
  #
  # Having multiple Mapnik::Map instances floating around can have a negative
  # impact on performance. Call map instead.
  #
  # @return {Mapnik::Map} map set up for rendering the game world
  def self.map!
    # The Google Maps projection.
    srs = '+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 ' +
          '+y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs +over'
    Mapnik::Map.new do |map|
      map.background = Mapnik::Color.new '#000'
      map.srs = srs

      map.layer 'roads' do |layer|
        layer.style do |style|
          style.rule do |default|
            default.line do |line|
              line.color = Mapnik::Color.new '#444444'
              line.gamma = 0.5
              line.line_join = Mapnik::LineJoin::BEVEL_JOIN
              line.line_cap = Mapnik::LineCap::BUTT_CAP
              line.width = 3
            end
          end
        end
        layer.srs = srs
        layer.datasource = Mapnik::Datasource.create type: 'postgis',
            dbname: 'netmap-gis', table: 'planet_osm_line'
      end

      map.layer 'buildings' do |layer|
        layer.style do |style|
          style.rule do |default|
            default.polygon do |polygon|
              polygon.fill = Mapnik::Color.new '#193B4D'
            end
            default.line do |line|
              line.color = Mapnik::Color.new '#136086'
              line.line_join = Mapnik::LineJoin::BEVEL_JOIN
              line.line_cap = Mapnik::LineCap::BUTT_CAP
              line.width = 1
            end
          end
        end
        layer.srs = srs
        layer.datasource = Mapnik::Datasource.create type: 'postgis',
            dbname: 'netmap-gis', table: <<TABLE_END.strip
(select way, building, leisure, railway, amenity, aeroway
    from planet_osm_polygon
    where building is not null or railway='station' or
          amenity='place_of_worship' or aeroway='terminal'
    order by z_order, way_area desc) as buildings
TABLE_END
      end

    end
  end
end
