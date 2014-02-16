# resource with basic interface
# encoding: UTF-8
class ResourceDecorator
  def initialize(resource)
    @to_decorate = resource
    @resource_as_hash = {name: @to_decorate.name, description: @to_decorate.description}
  end
  
  def as_if_i_had_a_location(url)
    as_if_i_were_hash.merge({links: [{rel: 'self', uri: "#{url}/#{as_if_i_were_a_number}"}]})
  end

  def as_if_i_had_actions(url, *args)
    actions = [{rel: 'self', uri: "#{url}"}]
    args.each {|action| actions << {rel: "#{action}", uri:"#{url}/#{action}" } }
    as_if_i_were_hash.merge(   {links:actions}    )
  end

  def as_if_i_were_json
    JSON.pretty_generate(@resource_as_hash)
  end
  
  def as_if_i_were_hash
    @resource_as_hash
  end

  def as_if_i_were_a_number
    @to_decorate.id.to_s
  end
end
