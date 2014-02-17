# resource with basic interface
# encoding: UTF-8
require_relative 'default_behaviour'
class ResourceDecorator
  include Getter
  def initialize(resource)
    @to_decorate = resource
    @resource_as_hash = { name: @to_decorate.name, description: @to_decorate.description }
  end

  def generate_self(url)
    {rel: "self",uri: "#{url}/resources/#{as_if_i_were_a_number}"}
  end

  def generate_booking(url)
    {rel: "bookings",uri: "#{url}/resources/1/bookings"}
  end
end
