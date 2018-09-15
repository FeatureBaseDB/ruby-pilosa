require "json"
require "net/http"
require "uri"
require "pilosa/proto/public_pb"

module Pilosa
  class Client
    attr_reader :uris

    def initialize(uris=[])
      uris = [uris] if uris.is_a?(String)
      uris = uris.map { |uri| URI(uri) }
      uris = [DEFAULT_URI] if uris.empty?
      @uris = uris
    end

    # Creates a new index.
    def create_index(name, **options)
      options = {
        keys: false,
      }.merge(options)

      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/index/#{name}"

      # Send HTTP request.
      req = Net::HTTP::Post.new(uri)
      req.body = JSON.generate({options: options})
      req['Content-Type'] = "application/json"
      req['Accept'] = "application/json"
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      case resp.code.to_i
      when 200
        return nil
      when 409
        raise IndexExistsError.new("Index already exists")
      else
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end
    end

    # Removes an existing index.
    def delete_index(name)
      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/index/#{name}"

      # Send HTTP request.
      req = Net::HTTP::Delete.new(uri)
      req['Content-Type'] = "application/json"
      req['Accept'] = "application/json"
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      case resp.code.to_i
      when 200
        return nil
      else
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end
    end

    # Creates a new field on an index.
    def create_field(index, name, **options)
      options = {
        type: "",
      }.merge(options)


      # Convert to camel case.
      options[:cacheType] = options.delete(:cache_type) if options.key?(:cache_type)
      options[:cacheSize] = options.delete(:cache_size) if options.key?(:cache_size)
      options[:timeQuantum] = options.delete(:time_quantum) if options.key?(:time_quantum)

      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/index/#{index}/field/#{name}"

      # Send HTTP request.
      req = Net::HTTP::Post.new(uri)
      req.body = JSON.generate({options: options})
      req['Content-Type'] = "application/json"
      req['Accept'] = "application/json"
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      case resp.code.to_i
      when 200
        return nil
      when 409
        raise FieldExistsError.new("Field already exists")
      else
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end
    end

    # Removes an existing field.
    def delete_field(index, name)
      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/index/#{index}/field/#{name}"

      # Send HTTP request.
      req = Net::HTTP::Delete.new(uri)
      req['Content-Type'] = "application/json"
      req['Accept'] = "application/json"
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      case resp.code.to_i
      when 200
        return nil
      else
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end
    end

    # Executes a PQL query against the index.
    def query(index, query, **options)
      # Set default options.
      options = {
        shards: [],
        column_attrs: false,
        exclude_row_attrs: false,
        exclude_columns: false,
      }.merge(options)

      # Build protobuf request object.
      request = GopilosaPbuf::QueryRequest.new(
        Query: query,
        Shards: options[:shards],
        ColumnAttrs: options[:column_attrs],
        ExcludeRowAttrs: options[:exclude_row_attrs],
        ExcludeColumns: options[:exclude_columns],
      )

      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/index/#{index}/query"

      # Send HTTP request.
      req = Net::HTTP::Post.new(uri)
      req.body = GopilosaPbuf::QueryRequest.encode(request)
      req['Content-Type'] = "application/x-protobuf"
      req['Accept'] = "application/x-protobuf"
      req['PQL-Version'] = PQL_VERSION,
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      if resp.code.to_i < 200 || resp.code.to_i >= 300
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end

      # Decode response.
      response = GopilosaPbuf::QueryResponse.decode(resp.body)
      if response.Err != ""
        raise PilosaError.new(response.Err)
      end

      # Convert types.
      return QueryResponse.decode(response)
    end

    # Retrieves the status from the server.
    def status()
      # Build URI.
      uri = @uris.sample.clone()
      uri.path = "/status"

      # Send HTTP request.
      req = Net::HTTP::Get.new(uri)
      req['Content-Type'] = "application/json"
      req['Accept'] = "application/json"
      resp = Net::HTTP.new(uri.host, uri.port).request(req)

      # Handle unsuccessful error code.
      case resp.code.to_i
      when 200
        return Status.decode(JSON.parse(resp.body))
      else
        raise PilosaError.new("Server error (#{resp.code}): #{resp.body}")
      end
    end
  end
end