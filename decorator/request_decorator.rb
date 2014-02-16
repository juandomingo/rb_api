# resource with basic interface
# encoding: UTF-8
class RequestDecorator
  def initialize(request)
    @request = request
    @resource_as_json = JSON.pretty_generate{from: @request.from, to:@request.to,status:@request.status,user:@request.user,name:@request.name}
  end 
  # def from_json() 
  #   json
 #       Request.create(name: "David", occupation: "Code Artist")
  # end 
  def to_json
    @resource_as_json
    end
end