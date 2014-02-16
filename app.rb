# encoding: UTF-8
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'app_helper'

def self.root
  File.dirname(__FILE__)
end

before do
    content_type :json
end

get '/' do
  'Hello World'
end

get '/resources' do
  array_to_show = []
  Resource.all.each {|one_resource| 
    pepino = ResourceDecorator.new(one_resource)
    array_to_show << pepino.as_if_i_had_a_location(request.url)
  }
  hash_to_show = {resources: array_to_show}
  JSON.pretty_generate(hash_to_show)
end

get '/resources/:id' do
  the_hash = { resource: ResourceDecorator.new(Resource.find(params[:id])).as_if_i_had_actions( request.url, 'booking' )  }
  JSON.pretty_generate(the_hash)

end

get '/create' do
  Resource.create(name: 'ventilador', description: 'Ventilador de pie con astas metálicas')
end

get '/pija' do 
  ResourceDecorator.new(Resource.find(1)).as_if_i_were_json
end

get '/put' do
  puts request.url
  puts request.base_url
  Resource.find(1).id.to_s
end