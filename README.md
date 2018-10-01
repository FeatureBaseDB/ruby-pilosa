ruby-pilosa
===========

This repository is the official Ruby client library for the Pilosa server.
It implements the basic client query and schema operations but does not
implement an ORM on top of the PQL language.


## Installation

Use rubygems to install `pilosa`:

```sh
$ gem install pilosa
```

Then simply require `pilosa` to use it in your application:

```rb
require 'pilosa'
```


## Usage

### Initializing the client

Before you can run queries, you must first set up your Pilosa client. The
`Client.new()` function accepts a single URI of your Pilosa server or an
array or URIs if you are running a cluster of Pilosa servers.

```rb
# Default clienting connecting to http://localhost:10101
client = Pilosa::Client.new()
```

```rb
# Client connecting to a single Pilosa server.
client = Pilosa::Client.new('http://myserver:10101')
```

```rb
# Client connecting to a Pilosa cluster.
client = Pilosa::Client.new(['http://myserver1:10101', 'http://myserver2:10101'])
```


### Error handling

All errors produced by this library are of class `Pilosa::PilosaError`. In
addition to generic errors, some methods may produce specific error types
such as `Pilosa::IndexExistsError` which are also subclasses of `PilosaError`.


### Index management

Once your client is set up, you can read, create, and delete indexes on the
server.

```rb
# Create an index named "myidx".
client.create_index('myidx')

# Create an index that uses string keys instead of IDs.
client.create_index('idx_with_keys', keys: true)
```

```rb
# Delete an existing index named "myidx".
client.delete_index('myidx')
```


### Field management

After you create your index, you can create fields on your index:

```rb
# Create a field named "myfield".
client.create_field('myidx', 'myfield')

# Create an integer field.
client.create_field('integer_field', type: :int)
```

```rb
# Delete an existing index named "myfield".
client.delete_field('myfield')
```


### Executing Queries

Inserting data and querying for data can be done using the `query()` method
and the [Pilosa Query Language (PQL)](https://www.pilosa.com/docs/latest/query-language/).
Each command in PQL will return a separate result in the response.

```rb
# Set "myfield" to 1 on column 10.
resp = client.query('myidx', 'Set(10, myfield=1)')
puts resp.results[0].changed # => true
```

Many PQL queries return row results:

```rb
# Read the data for myfield row 1.
resp = client.query('myidx', 'Row(myfield=1)')
puts resp.results[0].row.columns # => [10]
```



## Development

### Testing

To run the tests, simply run:

```sh
$ rake test
```

