# resource with basic interface
# encoding: UTF-8
require 'date'
require 'time'
require_relative 'default_behaviour'
class RequestDecorator
  include Getter
  def initialize(request)
    @to_decorate = request
    @resource_as_hash = { from: @to_decorate.from, to: @to_decorate.to, status: @to_decorate.status, user: @to_decorate.user }
  end

  def am_i_later?(a_date)
  	(@to_decorate.from) >= a_date
  end

  def am_i_previous?(a_date)
  	(@to_decorate.to) <= a_date
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
end
