$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.unshift(File.dirname(__FILE__) + '/../../../rails/activesupport/lib')
$:.unshift(File.dirname(__FILE__) + '/../../../rails/activerecord/lib')

require 'test/unit'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'
require 'technoweenie/active_record_context'
require 'rubygems'
require 'mocha'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite'])

load(File.dirname(__FILE__) + "/schema.rb")

ActiveRecord::Base.send :include, Technoweenie::ActiveRecordContext

class Topic < ActiveRecord::Base
end

class Post < ActiveRecord::Base; end
class NormalPost < Post
  belongs_to :topic
end

class PolymorphPost < Post
  belongs_to :topic, :polymorphic => true
end