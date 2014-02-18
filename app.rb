# encoding: UTF-8
require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym
require_relative 'app_helper'

before do
  content_type :json
end

error ActiveRecord::RecordNotFound do
  redirect to(not_found)
end

def conflict
  status 408
  'conflict'
end

error do
end

def self.root
  File.dirname(__FILE__)
end

get '/resources' do
  array_to_show = []
  Resource.all.each { |one_resource| array_to_show << ResourceDecorator.new(one_resource).as_if_i_had_actions(request.base_url, 'self') }
  JSON.pretty_generate({ resources: array_to_show, links: [rel: 'self', uri: "#{request.url}"] })
end

get '/resources/:id' do
  begin
    JSON.pretty_generate({ resource: ResourceDecorator.new(Resource.find(params[:id])).as_if_i_had_actions(request.url, 'self', 'booking') })
  rescue ActiveRecord::RecordNotFound
    halt 404
  end
end

get '/resources/:id/bookings' do
  params[:date] = Date.today.next_day.iso8601 if params[:date].nil?
  params[:limit] = 30 if params[:limit].nil?
  params[:status] = 'approved' if params[:status].nil?

  halt 404 if params[:limit].to_s > '365'
  halt 404 unless ['approved', 'pending', 'all'].include?params[:status]
  halt 404 unless %r(^$\d{4}-\d{1,2}-\d{1,2}.*).match(params[:date])

  array_to_show = []
  Request.all.each do |one_request|
    one_decored_request = RequestDecorator.new(one_request)
    array_to_show << one_decored_request.as_if_i_had_actions(request.base_url, 'self', 'resource', 'accept', 'reject') if one_decored_request.am_i_?(params[:status]) && one_decored_request.am_i_between_?(params[:date], params[:limit]) && one_decored_request.am_i_requesting_resource_number?(params[:id])
  end
  JSON.pretty_generate({ bookings: array_to_show, links: [rel: 'self', uri: "#{request.url}"] })
end

get '/resources/:id/availability' do
  params[:date] = Date.today.next_day.iso8601 if params[:date].nil?
  params[:limit] = 30 if params[:limit].nil?

  halt 404 if params[:limit].to_i > 365
  halt 404 unless /^$\d{4}-\d{1,2}-\d{1,2}.*/.match(params[:date])

  base_array = []
  Request.all.each do |one_request|
    one_decored_request = RequestDecorator.new(one_request)
    base_array << one_decored_request.as_if_i_were_an_intiger_time_lapse if one_decored_request.am_i_approved? && one_decored_request.am_i_between_?(params[:date], params[:limit]) && one_decored_request.am_i_requesting_resource_number?(params[:id])
  end
  time_array = [(Time.parse(params[:date]).to_i..Time.parse(params[:date]).to_i + params[:limit].to_i * SECONDS_IN_A_DAY)]
  base_array.each  do |each_a|
    time_array.each do |each_t|
      if (each_t.include?(each_a.min)) && (each_t.include?(each_a.max))
        time_array = time_array - [each_t]
        time_array = time_array + [(each_t.min...each_a.min), (each_a.max...each_t.max)]
      end
    end
  end
  hash_to_show = []
  time_array.each  do |each_one|
    hash_to_show << { from: Time.at(each_one.min).strftime("%Y-%m-%dT%H:%M:%SZ"),
                      to: Time.at(each_one.max).strftime("%Y-%m-%dT%H:%M:%SZ"),
                      links: [{ rel: 'book',
                                link: "#{request.base_url}/resources/#{params[:id]}/bookings",
                                method: 'POST' },
                              { rel: 'resource',
                                uri: "#{request.base_url}/resources/#{params[:id]}" }] }
  end
  JSON.pretty_generate({ availability: hash_to_show, links: [{ rel: 'self', link: "#{request.url}" }] })

end

post '/resources/:id/bookings' do
  halt 404 if params[:from].nil?
  halt 404 unless /^\d{4}-\d{1,2}-\d{1,2}.*/.match(params[:from])

  params[:to] = Date.today.next_day(365).iso8601 if params[:to].nil?
  halt 404 unless /^\d{4}-\d{1,2}-\d{1,2}.*/.match(params[:to])
  base_array = []
  Request.all.each do |one_request|
    one_decored_request = RequestDecorator.new(one_request)
    base_array << one_decored_request if one_decored_request.am_i_between?(params[:from], params[:to]) && one_decored_request.am_i_approved? && one_decored_request.am_i_requesting_resource_number?(params[:id])
  end
  if base_array.empty?
    JSON.pretty_generate({ book: RequestDecorator.new(Request.create!(user: 'domingo@gmail.com', from: "#{params[:from]}", to: "#{params[:to]}", status: 'pending', resources_id: "#{params[:id]}")).as_if_i_had_actions(request.base_url, 'self', 'accept', 'reject') })
    status 201
  else
    status 408
  end
end

delete '/resources/:id/bookings/:id_request' do
  halt 404 if RequestDecorator.new(Request.find(params[:id_request])).nil?
  requested = RequestDecorator.new(Request.find(params[:id_request]))
  requested.delete!
  status 200
end

get '/resources/:id/bookings/:id_request' do
  requested = Request.find(params[:id_request])
  JSON.pretty_generate(RequestDecorator.new(requested).as_if_i_had_actions(request.base_url, 'self', 'resource', 'accept', 'reject'))
end

put '/resources/:id/bookings/:id_request' do
  requested = Request.find(params[:id_request])
  requested = RequestDecorator.new(requested)
  base_array = []
  Request.all.each  do |one_request|
    one_decored_request = RequestDecorator.new(one_request)
    base_array << one_decored_request if one_decored_request.am_i_pending? && one_decored_request.am_i_touching?(requested) && one_decored_request.am_i_requesting_resource_number?(params[:id])
  end
  base_array.each { |unfortunated_request| unfortunated_request.cancel! }
  requested.accept!
  JSON.pretty_generate({ book: requested.as_if_i_had_actions(request.base_url, 'self', 'accept', 'reject', 'resource') })
end
