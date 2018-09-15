require "pilosa/proto/public_pb"

module Pilosa
  class ValCount
    attr_reader :val, :count

    def initialize(**options)
      @val = options[:val]
      @count = options[:count]
    end

    def self.decode(pb)
      return ValCount.new(
        val: pb.Val,
        count: pb.Count,
      ) unless pb.nil?
    end
  end
end
