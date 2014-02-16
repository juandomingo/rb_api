# encoding: UTF-8
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym
require 'rubygems'
require 'sinatra'
require 'active_record'
require 'sinatra/reloader'
require 'json'

def self.root
  File.dirname(__FILE__)
end
require_relative 'model/resource'
require_relative 'model/request'
require_relative 'decorator/resource_decorator'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db/test.sqlite3'
)
get '/' do
  'Hello World'
end

get '/resources' do
  content_type :json
  Resource.to_json request.base_url
end

get '/create' do
  Resource.create(name: 'ventilador', description: 'Ventilador de pie con astas metálicas')
end

get '/pija' do
  varia = Resource.find(1)
  tuvieja = ResourceDecorator.new(varia)
  tuvieja.as_if_it_were_json
end