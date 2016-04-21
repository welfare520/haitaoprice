class MongoConfig

  attr_reader :mongo_config

  def initialize
    file = File.join(File.dirname(__FILE__), 'mongo.yaml')
    config = YAML.load_file(file)
    raise "cannot load configuration yaml" if config == nil

    @mongo_config = config[ENV['RACK_ENV'] || 'defaults']
    raise "cannot configure Mongodb" if @mongo_config.nil?
  end

  def host
    @mongo_config['host']
  end

  def port
    @mongo_config['port']
  end

  def dbname
    @mongo_config['dbname']
  end

  def dump_path 
    @mongo_config['dump_path']
  end
end
