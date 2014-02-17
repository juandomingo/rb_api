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
    array_to_show << ResourceDecorator.new(one_resource).as_if_i_had_actions(request.base_url,'self')
  }
  JSON.pretty_generate({resources: array_to_show, links: [rel:'self', uri: "#{request.url}"]})
end

get '/resources/:id' do
  begin
    JSON.pretty_generate({ resource: ResourceDecorator.new(Resource.find(params[:id])).as_if_i_had_actions( request.url, 'booking' )  })
  rescue ActiveRecord::RecordNotFound
    redirect 'not_found'
  end 
end

get '/resources/:id/bookings' do 
  params[:date]=Date.today.next_day.iso8601 if params[:date].nil? 
  params[:limit]=30 if params[:limit].nil? 
  params[:status]='approved' if params[:status].nil?  
  

  redirect 'error' if params[:limit].to_i > 365
  redirect 'error' unless ['approved','pending','all'].include?params[:status] 
  redirect 'error' unless /\d{4}-\d{1,2}-\d{1,2}/.match(params[:date])

  array_to_show = []
  Request.all.each {|one_request| 
    one_decored_request = RequestDecorator.new(one_request)
    array_to_show << one_decored_request.as_if_i_had_actions(request.base_url,'self','resource', 'accept','reject') if one_decored_request.am_i_?(params[:status])&&one_decored_request.am_i_between_?(params[:date], params[:limit])&&one_decored_request.am_i_requesting_resource_number?(params[:id])
  }
  JSON.pretty_generate({bookings: array_to_show, links: [rel:'self', uri: "#{request.url}"]})
end



get '/resources/:id/availability' do
  params[:date]=Date.today.next_day.iso8601 if params[:date].nil? 
  params[:limit]=30 if params[:limit].nil? 

  redirect 'error' if params[:limit].to_i > 365
  redirect 'error' unless /\d{4}-\d{1,2}-\d{1,2}/.match(params[:date])

  base_array = []
  Request.all.each {|one_request| 
    one_decored_request = RequestDecorator.new(one_request)
    base_array << one_decored_request.as_if_i_were_an_intiger_time_lapse if one_decored_request.am_i_approved?&&one_decored_request.am_i_between_?(params[:date], params[:limit])&&one_decored_request.am_i_requesting_resource_number?(params[:id])
  }

  time_array = [(Time.parse(params[:date]).to_i..Time.parse(params[:date]).to_i + params[:limit].to_i*SECONDS_IN_A_DAY)]

  base_array.each{ |each_a|
    time_array.each{ |each_t|if (each_t === each_a.min)&&(each_t === each_a.max) then
      puts "test_hola"
      time_array = time_array - [each_t] 
      time_array = time_array + [(each_t.min...each_a.min),(each_a.max...each_t.max)]
    end
    }
  }

  hash_to_show = []
  time_array.each{ |each_one| hash_to_show << {from: Time.at(each_one.min).strftime("%Y-%m-%dT%H:%M:%SZ"),
    to: Time.at( each_one.max).strftime("%Y-%m-%dT%H:%M:%SZ"),
    links:[{rel: "book",link: "#{request.base_url}/resources/#{params[:id]}/bookings",method: "POST"},
        {rel: "resource",uri: "#{request.base_url}/resources/#{params[:id]}"},]} } 
  
  JSON.pretty_generate({availability: hash_to_show, links: [{ rel: "self",link: "#{request.url}"}]})  
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
