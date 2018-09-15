require "pilosa/proto/public_pb"

module Pilosa
  class Attrs
    def self.decode(pb)
      h = {}
      pb.each do |item|
        h[item.Key] = case item.Type
        when 1 then item.StringValue
        when 2 then item.IntValue
        when 3 then item.BoolValue
        when 4 then item.FloatValue
        end
      end
      return h
    end
  end
end
