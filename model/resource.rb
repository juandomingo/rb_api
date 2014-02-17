# encoding: UTF-8
# ActiveRecord class for Resource
class Resource < ActiveRecord::Base
  validates :name, :description, presence: true
  validates :description, length: { maximum: 255 }
end
# t.string "name"
# t.text   "description"