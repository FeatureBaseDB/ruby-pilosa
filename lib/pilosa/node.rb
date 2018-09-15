require "pilosa/proto/public_pb"

module Pilosa
  class Node
    attr_reader :id, :uri, :is_coordinator

    def initialize(**options)
      @id = options[:id]
      @uri = options[:uri]
      @is_coordinator = options[:is_coordinator]
    end

    def self.decode(js)
      return Node.new(
        id: js["id"],
        uri: URI("#{js['uri']['scheme']}://#{js['uri']['host']}:#{js['uri']['port']}"),
        is_coordinator: js["isCoordinator"],
      )
    end
  end
end

