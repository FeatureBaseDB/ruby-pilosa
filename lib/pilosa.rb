require "pilosa/attrs"
require "pilosa/client"
require "pilosa/column_attr_sets"
require "pilosa/node"
require "pilosa/pair"
require "pilosa/query_response"
require "pilosa/query_result"
require "pilosa/row"
require "pilosa/status"
require "pilosa/val_count"

require "uri"

module Pilosa
  DEFAULT_URI = URI('http://127.0.0.1:10101')

  PQL_VERSION = '1.0'

  class PilosaError < RuntimeError; end
  class IndexExistsError < PilosaError; end
  class FieldExistsError < PilosaError; end
end