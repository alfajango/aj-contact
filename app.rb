require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'sequel'

config do
  Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/aj-contact')
end

DB.create_table :submissions do
    primary_key :id
    column :name, :text
    column :email, :text
    String :message
end

class Submission < Sequel::Model; end

post '/contact' do
  Submission.create(:name => params[:name], params[:email], :message => params[:message])
end
