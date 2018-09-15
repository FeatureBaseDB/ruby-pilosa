require "pilosa/proto/public_pb"

module Pilosa
  class Row
    attr_reader :columns, :keys, :attrs

    def initialize(**options)
      @columns = options[:columns]
      @keys = options[:keys]
      @attrs = options[:attrs]
    end

    def self.decode(pb)
      return Row.new(
        columns: pb.Columns,
        keys: pb.Keys,
        attrs: Attrs.decode(pb.Attrs),
      ) unless pb.nil?
    end
  end
end