# resource with basic interface
# encoding: UTF-8
# you will probably wan't to change am_i_all? and am_i_?(what) depending on your requirements
require 'date'
require 'time'
require_relative 'default_behaviour'
class RequestDecorator
  include Getter
  def initialize(request)
    @to_decorate = request
    @resource_as_hash = { start: @to_decorate.from, end: @to_decorate.to, status: @to_decorate.status, user: @to_decorate.user }
  end

  def am_i_later?(a_date)
  	  (@to_decorate.from) >= a_date
  end

  def am_i_previous?(a_date)
  	  if @to_decorate.to.nil?
        return false
      else
        (@to_decorate.to) <= a_date
    end
  end

  def as_if_i_had_no_username
    momento = @resource_as_hash.clone
    momento.delete(:user)
    momento
  end

  def am_i_previous_?(base_date,days_from_base)
    am_i_previous?(Time.parse(base_date) + (days_from_base.to_i * 24 * 60 * 60))
  end
  
  def am_i_between?(base_date, last_day)
  	am_i_later?(base_date)&&am_i_previous?(last_day)
  end

  def am_i_between_?(base_date, days_from_base)
    am_i_later?(base_date)&&am_i_previous_?(base_date,days_from_base)
  end

  def am_i_approved?
    @to_decorate.status == 'approved'
  end

  def am_i_pending?
    @to_decorate.status == 'pending'
  end

  def am_i_canceled?
    @to_decorate.status == 'cancel'
  end

  def am_i_requesting_resource_number?(number)
    @to_decorate.resources_id.to_s == number.to_s
  end
  
  def am_i_all?
    ['approved','pending'].include?@to_decorate.status
  end

  def am_i_?(what)
    false unless ['approved','pending','canceled','all'].include?what 
    eval("am_i_#{what}?")
  end

  def my_resource_id
    @to_decorate.resources_id.to_s
  end

  def generate_self(url)
    {rel: "self",uri: "#{url}/resources/#{my_resource_id}/bookings/#{as_if_i_were_a_number}"}
  end

  def generate_accept(url)
    {rel: "accept",uri: "#{url}/resources/#{my_resource_id}/bookings/#{as_if_i_were_a_number}",method: "PUT"}
  end 

  def generate_reject(url)
    {rel: "reject",uri: "#{url}/resources/#{my_resource_id}/bookings/#{as_if_i_were_a_number}",method: "DELETE"}
  end

  def generate_resource(url)
    {rel: "resource",uri: "#{url}/resources/#{my_resource_id}"}
  end

  def as_if_i_were_an_intiger_time_lapse
    (@to_decorate.from.to_i..@to_decorate.to.to_i)     
  end

  def as_just_from
    @to_decorate.from
  end

  def as_just_to
    @to_decorate.to
  end

  def am_i_touching?(other_request)
    (as_just_from <= other_request.as_just_to) and (as_just_to >= other_request.as_just_from)
  end
  
  def delete!
    Request.delete(Request.find(as_if_i_were_a_number))
  end

  def accept!
    Request.update(as_if_i_were_a_number, status:'accepted')
  end

  def cancel!
    Request.update(as_if_i_were_a_number, status:'canceled')
  end  
end
