class AuthConfig

  attr_reader :auth_config

  def initialize
    file = File.join(File.dirname(__FILE__), 'auth.yaml')
    config = YAML.load_file(file)
    raise "cannot load configuration yaml" if config == nil

    @auth_config = config[ENV['RACK_ENV']]
    raise "cannot configure authentication" if @auth_config.nil?
  end

  def user
    @auth_config['user']
  end

  def pass
    @auth_config['pass']
  end

end
