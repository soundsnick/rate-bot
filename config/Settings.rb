require 'yaml'

class Settings
  # description: Interface for the config YML file

  @settings = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config.yml')))

  def self.bot
    @settings['bot']
  end

  def self.api
    @settings['api']
  end

  def self.tables
    @settings['tables']
  end

end
