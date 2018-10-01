require "pilosa/proto/public_pb"

module Pilosa
  class QueryResponse
    attr_reader :results, :column_attr_sets

    def initialize(**options)
      @results = options[:results]
      @column_attr_sets = options[:column_attr_sets]
    end

    def self.decode(pb)
      return QueryResponse.new(
        results: pb.Results.map { |result| QueryResult.decode(result) },
        column_attr_sets: ColumnAttrSets.decode(pb.ColumnAttrSets),
      )
    end
  end
end
