# encoding: UTF-8
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym
require_relative 'app_helper'

not_found do
  'Not Found'
end

error do
  'Error'
end

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
    array_to_show << ResourceDecorator.new(one_resource).as_if_i_had_a_location(request.url)
  }
  JSON.pretty_generate({resources: array_to_show, links: [rel:'self', uri: "#{request.base_url}"]})
end

get '/resources/:id' do
  begin
    JSON.pretty_generate({ resource: ResourceDecorator.new(Resource.find(params[:id])).as_if_i_had_actions( request.url, 'booking' )  })
  rescue ActiveRecord::RecordNotFound
    redirect 'not_found'
  end 
end

get '/resources/:id/bookings' do
  params[:date]=Date.today.next_day.iso8601 unless !params[:date].nil?
  params[:limit]=Date.today.next_day(30).iso8601 unless !params[:limit].nil? 
  params[:status]='approved' unless ! params[:status].nil?  
  array_to_show = []
  ar_querry = "'resources_id' = :resources_id"
  Request.all.each {|one_request| 
    array_to_show << RequestDecorator.new(one_request).as_if_i_had_a_location(request.url) unless !RequestDecorator.new(one_request).am_i_between_?(params[:date], params[:limit]) 
  }
  JSON.pretty_generate({resources: array_to_show, links: [rel:'self', uri: "#{request.base_url}"]})

  # end_date = Time.parse(date) + (limit * 24 * 60 * 60)
  # str_start = date.to_s + ' 00:00:00'
  # str_end = end_date.strftime('%Y-%m-%d').tho_s + ' 23:59:59'
  #   all_exp = 
  # else_exp = "resource_id = :res_id AND status = :status AND
  #   start <= :end_date AND end > :start_date"
  # use = status == 'all' ? all_exp : else_exp
  # Booking.where( 
  #   use,
  #   res_id: res_id, start_date: start_d,
  #   end_date: end_d, status: status
  # )
end

get '/create' do
  Resource.create(name: 'ventilador', description: 'Ventilador de pie con astas metálicas')
end

get '/algo' do 
  JSON.pretty_generate(RequestDecorator.new(Request.first).as_if_i_had_actions( request.url, 'booking' )) 
end

get '/put' do
  puts request.url
  puts request.base_url
  Resource.find(1).id.to_s
end
