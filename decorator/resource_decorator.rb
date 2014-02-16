# resource with basic interface
# encoding: UTF-8
require_relative 'default_behaviour'
class ResourceDecorator
  include Getter
  def initialize(resource)
    @to_decorate = resource
    @resource_as_hash = { name: @to_decorate.name, description: @to_decorate.description }
  end
end
