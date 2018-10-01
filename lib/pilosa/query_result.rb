require "pilosa/proto/public_pb"

module Pilosa
  class QueryResult
    attr_reader :type, :row, :n, :pairs, :val_count, :changed

    def initialize(**options)
      @type = options[:type]
      @row = options[:row]
      @n = options[:n]
      @pairs = options[:pairs]
      @val_count = options[:val_count]
      @changed = options[:changed]
    end

    def self.decode(pb)
      return QueryResult.new(
        type: decode_type(pb.Type),
        row: Row.decode(pb.Row),
        n: pb.N,
        pairs: pb.Pairs.map { |pair| Pair.decode(pair) },
        val_count: ValCount.decode(pb.ValCount),
        changed: pb.Changed,
      ) unless pb.nil?
    end

    def self.decode_type(type)
      case type
      when 0 then :nil
      when 1 then :row
      when 2 then :pairs
      when 3 then :val_count
      when 4 then :uint64
      when 5 then :bool
      end
    end
  end
end
