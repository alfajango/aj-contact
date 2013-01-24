require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'sequel'

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres@localhost/aj_contact')
end

DB.create_table :submissions, :if_not_exists => true do
    primary_key :id
    column :name, :text
    column :email, :text
    String :message
end

class Submission < Sequel::Model; end

post '/contact' do
  puts "Contact submission:"
  puts params
  Submission.create(:name => params[:name], :email => params[:email], :message => params[:message])
  redirect 'http://localhost:4000/thank_you'
end
