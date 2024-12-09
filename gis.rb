#!/usr/bin/env ruby

class Track
  def initialize(segments, name=nil)
    @name = name
    @segments = segments
  end

  def get_json()
    json = '{'
    json += '"type": "Feature", '
    if @name != nil
      json += '"properties": {'
      json += '"title": "' + @name + '"'
      json += '},'
    end
    json += '"geometry": {'
    json += '"type": "MultiLineString",'
    json +='"coordinates": ['
    json = append_segments_json(json)
    json + ']}}'
  end

  def append_segments_json(json)
    @segments.each_with_index do |segment, index|
      json = segment.append_segment_json(json)
    end
    return json
  end
end

class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def append_segment_json(json)
    if index > 0
      json += ","
    end
    json += '['
    segment.coordinates.each_with_index do |coordinates, coordinate_count|
      if coordinate_count != 0
        json += ','
      end
      json = coordinates.append_coords_json(json)
    end
    json += ']'
    return json
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

  def append_coords_json(json)
    json += "[#{@lon},#{@lat}"
    if ele != nil
      json += ",#{@ele}"
    end
    json += ']'
    return json
  end
end

class Waypoint

  attr_reader :coordinates, :name, :type

  def initialize(coordinates, name=nil, type=nil)
    @coordinates = coordinates
    @name = name
    @type = type
  end

  def get_json(indent=0)
    json = '{"type": "Feature",'
    json += '"geometry": {"type": "Point","coordinates": '
    json = coordinates.append_coords_json(json)
    json += '},'
    if name != nil or type != nil
      json += '"properties": {'
      if name != nil
        json += '"title": "' + @name + '"'
      end
      if type != nil
        if name != nil
          json += ','
        end
        json += '"icon": "' + @type + '"' 
      end
      json += '}'
    end
    json += "}"
    return json
  end
end

class World

  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def to_geojson(indent=0)
    string = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature,feature_number|
      if feature_number != 0
        string +=","
      end
      string += feature.get_json
    end
    string + "]}"
  end
end

def main()

  waypoint1 = Waypoint.new(Point.new(-121.5, 45.5, 30), "home", "flag")
  waypoint2 = Waypoint.new(Point.new(-121.5, 45.6, nil), "store", "dot")
  
  track_segment1 = 
  TrackSegment.new([
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ])

  track_segment2 = 
  TrackSegment.new([ 
  Point.new(-121, 45), 
  Point.new(-121, 46), 
  ])

  track_segment3 = 
  TrackSegment.new([
  Point.new(-121, 45.5),
  Point.new(-122, 45.5),
  ])

  track1 = Track.new([track_segment1, track_segment2], "track 1")
  track2 = Track.new([track_segment3], "track 2")

  world = World.new("My Data", [waypoint1, waypoint2, track1, track2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

