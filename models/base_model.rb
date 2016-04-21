require 'virtus'

class BaseModel
  include Virtus.model  

  attribute :client  
  attribute :content 

  @@mongo_client ||= Mongo::Client.new([ MongoConfig.new.host.to_s + ':' + MongoConfig.new.port.to_s ], :database => MongoConfig.new.dbname.to_s)

  def self.mongo_client
    @@mongo_client
  end

  def setup_mysql_connection
    @client = Mysql2::Client.new(:host => mysql_config.host, 
                                 :port => mysql_config.port.to_i, 
                                 :username => mysql_config.user,
                                 :password => mysql_config.pass)    
  end

  def setup_mysql_bi_connection
    @client = Mysql2::Client.new(:host => mysql_config.bihost, 
                                 :port => mysql_config.biport.to_i, 
                                 :username => mysql_config.biuser,
                                 :password => mysql_config.bipass)    
  end

  def setup_impala_connection 
    @impala_conn = Impala.connect('10.212.1.16', 21000)
  end

  def execute_impala_query(sql)
    setup_impala_connection 
    @impala_conn.execute(sql)
  ensure 
    @impala_conn.close 
  end

  def mysql_config
    SQLConfig.new 
  end

  def execute_bi_query(sql)
    setup_mysql_bi_connection
    @client.query(sql)
  ensure 
    @client.close 
  end

  def execute_query(sql)
    setup_mysql_connection
    @client.query(sql)
  ensure 
    @client.close 
  end

  def find_by_id(id)
    @@mongo_client[self.class.name.to_sym].find(:id => id).first     
  end

  def save_one(hash, collection=nil)
    collection_name = collection.nil? ? self.class.name : collection.to_s
    @@mongo_client[collection_name.to_sym]
      .find(:id => hash["id"])
      .update_one(hash, { :upsert => true })
  end

  def load_all(collection = nil)
    collection_name = collection.nil? ? self.class.name : collection.to_s
    @content ||= @@mongo_client[collection_name.to_sym].find({})
  end
end