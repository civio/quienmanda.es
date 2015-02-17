class Topic < ActiveRecord::Base
	validates :title, presence: true, uniqueness: true
	validates :description, presence: true

	acts_as_url :title, url_attribute: :slug, only_when_blank: true
	def to_param
	  slug
	end
end
