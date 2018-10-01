require "pilosa/proto/public_pb"

module Pilosa
  class ColumnAttrSets
    def self.decode(pb)
      h = {}
      pb.each do |item|
        if item.Key.nil? || item.Key == ""
          h[item.ID] = Attrs.decode(item.Attrs)
        else
          h[item.Key] = Attrs.decode(item.Attrs)
        end
      end
      return h
    end
  end
end
