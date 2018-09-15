require 'test_helper'

class ClientTest < Minitest::Test
  def setup
    @index = "i#{rand(1000000)}"
    @client = Pilosa::Client.new()
    @client.create_index(@index)
  end

  def teardown
    @client.delete_index(@index)
  end

  def test_client_initialize_default
    client = Pilosa::Client.new()
    assert_equal client.uris, [URI("http://127.0.0.1:10101")]
  end

  def test_client_initialize_string
    client = Pilosa::Client.new("localhost:123")
    assert_equal client.uris, [URI("localhost:123")]
  end

  def test_client_initialize_array
    client = Pilosa::Client.new(["localhost:123", "localhost:456"])
    assert_equal client.uris, [URI("localhost:123"), URI("localhost:456")]
  end

  def test_client_query_set_bit
    @client.create_field(@index, "x")
    resp = @client.query(@index, 'Set(1, x=2)')
    assert_equal resp.results.length, 1
    assert resp.results[0].changed
  end

  def test_client_query_clear_bit
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'Set(3, x=2)')

    resp = @client.query(@index, 'Clear(1, x=2)')
    assert_equal resp.results.length, 1
    assert resp.results[0].changed

    resp = @client.query(@index, 'Clear(1, x=2)')
    assert_equal resp.results.length, 1
    assert !resp.results[0].changed

    resp = @client.query(@index, 'Row(x=2)')
    assert_equal resp.results[0].row.columns, [3]
  end

  def test_client_query_row
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'Set(3, x=2)')

    resp = @client.query(@index, 'Row(x=2) Row(x=3)')
    assert_equal resp.results.length, 2
    assert_equal resp.results[0].type, :row
    assert_equal resp.results[0].row.columns, [1, 3]
    assert_equal resp.results[1].type, :row
    assert_equal resp.results[1].row.columns, []
  end

  def test_client_query_row_attrs
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'SetRowAttrs(x, 2, username="mrpi", active=true)')

    resp = @client.query(@index, 'Row(x=2)')
    assert_equal resp.results[0].type, :row
    assert_equal resp.results[0].row.columns, [1]
    assert_equal resp.results[0].row.attrs, {"active"=>true, "username"=>"mrpi"}
  end

  def test_client_query_exclude_row_attrs
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'SetRowAttrs(x, 2, username="mrpi", active=true)')

    resp = @client.query(@index, 'Row(x=2)', exclude_row_attrs: true)
    assert_equal resp.results[0].type, :row
    assert_equal resp.results[0].row.columns, [1]
    assert_equal resp.results[0].row.attrs, {}
  end

  def test_client_query_col_attrs
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'SetColumnAttrs(1, username="mrpi", active=true)')

    resp = @client.query(@index, 'Row(x=2)', column_attrs: true)
    assert_equal resp.results[0].type, :row
    assert_equal resp.results[0].row.columns, [1]
    assert_equal resp.column_attr_sets, {1=>{"active"=>true, "username"=>"mrpi"}}
  end

  def test_client_query_count
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'Set(3, x=2)')

    resp = @client.query(@index, 'Count(Row(x=2))')
    assert_equal resp.results.length, 1
    assert_equal resp.results[0].type, :uint64
    assert_equal resp.results[0].n, 2
  end

  def test_client_query_topn
    @client.create_field(@index, "x")
    @client.query(@index, 'Set(1, x=2)')
    @client.query(@index, 'Set(3, x=2)')
    @client.query(@index, 'Set(4, x=2)')

    resp = @client.query(@index, 'TopN(x)')
    assert_equal resp.results.length, 1
    assert_equal resp.results[0].type, :pairs
    assert_equal resp.results[0].pairs.length, 1
    assert_equal resp.results[0].pairs[0].id, 2
    assert_equal resp.results[0].pairs[0].count, 3
  end

  def test_client_status
    status = @client.status()
    assert_equal status.state, 'NORMAL'
    assert_equal status.nodes.length, 1
    assert status.nodes[0].id != ""
    assert_equal status.nodes[0].uri, URI("http://localhost:10101")
    assert_equal status.nodes[0].is_coordinator, true
    assert_equal status.local_id, status.local_id
  end
end
