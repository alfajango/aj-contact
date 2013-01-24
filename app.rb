require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'sequel'
require 'pony'

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
  Submission.create(:name => params[:full_name], :email => params[:email], :message => params[:message])
  Pony.mail :to => "support@alfajango.com", :from => params[:email], :subject => "[AJ Contact Form] Submission from #{params[:full_name]}", :body => erb(:email)
  redirect 'http://localhost:4000/thank_you'
end
