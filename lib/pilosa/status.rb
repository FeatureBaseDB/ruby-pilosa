require "pilosa/proto/public_pb"

module Pilosa
  class Status
    attr_reader :state, :nodes, :local_id

    def initialize(**options)
      @state = options[:state]
      @nodes = options[:nodes]
      @local_id = options[:local_id]
    end

    def self.decode(js)
      return Status.new(
        state: js["state"],
        nodes: (js["nodes"] || []).map { |item| Node.decode(item) },
        local_id: js["localID"],
      )
    end
  end
end

