require 'json'

class ORM
  @file_name = File.join(File.dirname(__FILE__), "database.json")

  def self.get_schema
    database = File.open(@file_name)
    schema = JSON.parse(database.read)
    database.close
    return schema
  end

  def self.update_schema(payload)
    database = File.open(@file_name, "w")
    database.write(JSON.pretty_generate(payload))
    database.close
  end

  def self.get_table(table_name)
    schema = get_schema
    return schema[table_name]
  end

  def self.update_table(table_name, payload)
    new_schema = get_schema
    new_schema[table_name] = payload
    update_schema(new_schema)
  end

  def self.set_table_item(table_name, key, value)
    table = get_table(table_name)
    table[key] = value
    update_table(table_name, table)
  end

  def self.destroy_table_item(table_name, key)
    table = get_table(table_name)
    table.delete(key)
    update_table(table_name, table)
  end
end
