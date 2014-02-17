# encoding: UTF-8
# status Validator  ,no usado aun.
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless ['approved','canceled','waiting'].include?record.status
      record.errors[:status] << 'status should be one of the followings : approved, canceled or waiting'
    end
  end
end

# ActiveRecord class for Request
class Request < ActiveRecord::Base
  validates :from, :to, :status, :user, :resources_id, presence: true
  validates :user, length: { maximum: 255 }
end
# t.integer  "resources_id"
# t.string   "user"
# t.datetime "from"
# t.datetime "to"
# t.string   "status"