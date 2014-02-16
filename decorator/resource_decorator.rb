# resource with basic interface
# encoding: UTF-8
class ResourceDecorator
  def initialize(resource)
    @resource = resource
    @resource_as_hash = {name: @resource.name, description: @resource.description}
  end

  def as_if_it_were_json
    JSON.pretty_generate(@resource_as_hash)
  end
  def as_if_it_were_hash
    @resource_as_hash
  end
end
