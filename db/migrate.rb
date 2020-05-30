require 'json'

require_relative "../config/Settings"

unless File.exist?(File.join(File.dirname(__FILE__), "database.json"))
  file_name = File.new(File.join(File.dirname(__FILE__), "database.json"),  "w+")
  file = File.open(file_name, 'w')

  tmp_obj = {}
  Settings.tables.each{ |table| tmp_obj[table] = {} }

  file.write(tmp_obj.to_json)
  file_name.close
  file.close
end
