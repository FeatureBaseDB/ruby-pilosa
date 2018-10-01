require "pilosa/proto/public_pb"

module Pilosa
  class Pair
    attr_reader :id, :key, :count

    def initialize(**options)
      if !options.key?(:key) || options[:key] == ""
        @id = options[:id]
      else
        @key = options[:key]
      end
      @count = options[:count]
    end

    def self.decode(pb)
      return Pair.new(
        id: pb.ID,
        key: pb.Key,
        count: pb.Count,
      ) unless pb.nil?
    end
  end
end