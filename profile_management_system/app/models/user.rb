class User < ApplicationRecord
	has_secure_password

	include UserHelper
	include Elasticsearch::Model
	include Elasticsearch::Model::Callbacks

	after_commit on: [:create] do
		__elasticsearch__.index_document
	end

	after_commit on: [:update] do
		__elasticsearch__.update_document
	end

	#settings index: { number_of_shards: 1 } do
		#mapping dynamic: false do
			#indexes :name, type: 'keyword'
			#indexes :email, type: 'keyword'
			#indexes :phone_no, type: 'keyword'
		#end
	#end

	def self.search(params)
		field = params[:field]
		query = params[:query]
		data = self.__elasticsearch__.search({
			query: {
				bool: {
					must: {
						match_phrase_prefix: {
							"#{field}": "#{query}",
						}
					}
				}
			}
		}).records
		return data
	end


	#def as_indexed_json(options={}) {
		#{}"name" => name,
		#{}"email" => email,
		#{}"phone_no" => phone_no
		#}
	#end

	def self.insertion_in_es
		User.__elasticsearch__.client.indices.create \
		index: User.index_name, body: { settings: User.settings.to_hash, mappings: User.mappings.to_hash }

		User.find_each do |i|
			i.__elasticsearch__.index_document
		end
	end
=begin
	def initialize(email_id, password, user_auth_token)
	    @email_id = email_id
	    @password = password
	    @user_auth_token = user_auth_token
  	end
=end
	validates_presence_of :name, :email, :address, :birth_date, :phone_no
	validates :phone_no, length: { is: 10 }, numericality: { only_integer: true }, uniqueness: true
	validates :email, uniqueness: { case_Sensitive: false }
	validate :horizontal_hierarchy, :vertical_hierarchy, on: [:update, :create]

	def horizontal_hierarchy
		if parent_id.present? && User.where(parent_id: parent_id).count > 3
			errors.add(:horizontal_hierarchy, "Cant have more than 4 children")
		end
	end

	def vertical_hierarchy
		if self.parent.present?
			user_parent = get_user_object(parent_id)
			if user_parent.parent.present?
				user_grandparent = get_user_object(user_parent.parent_id)
				if user_grandparent.parent.present?
					errors.add(:vertical_hierarchy, "Cant have more than 2 levels")
				end
			end
		end
	end



	enum status: [:active, :inactive]
	enum profile_type: [:buyer, :owner, :broker]

	has_many :children, :class_name => 'User', :foreign_key => 'parent_id'
	belongs_to :parent, :class_name => 'User', optional: true, :foreign_key => 'parent_id'
  	

	attr_accessor :email_id, :user_password, :user_auth_token


	def self.redis_key_generate(email_id, user_password, user_auth_token)
		user_id = Rails.cache.read(user_auth_token, namespace: "cache")
		if user_auth_token && user_id
			@current_user = Rails.cache.read(user_id, namespace: "cache")
			if @current_user == nil
				@current_user = User.find_by(id: user_id)
				Rails.cache.write(user_id,@current_user,namespace: "cache", expires_in:1.day)
			end
			return user_auth_token if @current_user
		else
			user = User.find_by_email(email_id)
			if !user
				render plain: 'User doesnt exist'
			else
				if user.authenticate(user_password)
					require 'securerandom'
					random_token = SecureRandom.base64(16)
					Rails.cache.write(random_token, user.id, namespace: "cache", expires_in:1.day)
					Rails.cache.write(user.id, user, namespace: "cache", expires_in:1.day)
					@current_user = user
					return random_token
				else
					return nil
					#render plain: 'Wrong credentials, try again'
				end
			end
		end
		nil
	end

	
	def self.authenticate_using_redis(user_auth_token)
		user_id = Rails.cache.read(user_auth_token, namespace: "cache")
			if user_id
				user = Rails.cache.read(user_id, namespace: "cache")
				if user
					return user
				else
					user = User.find_by(id: user_id)
					if user
						Rails.cache.write(user_id, user, namespace: "cache")
						return user
					end
				end
			end
			nil
	end
end
