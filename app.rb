require "rubygems"
require "bundler/setup"

require 'sinatra'
require 'sequel'
require 'pony'

configure do
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres@localhost/aj_contact')

  if ENV['SENDGRID_USERNAME']
    Pony.options = {
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true
      }
    }
  end
end

DB.create_table :submissions, :if_not_exists => true do
    primary_key :id
    column :name, :text
    column :email, :text
    String :message
end

class Submission < Sequel::Model; end

get '/wakeup' do
  puts "Waking up..."
  render :nothing => true, :status => 200
end

post '/contact' do
  puts "Contact submission:"
  puts params
  Submission.create(:name => params[:full_name], :email => params[:email], :message => params[:message])
  Pony.mail :to => "support@alfajango.com", :from => params[:email], :subject => "[AJ Contact Form] Submission from #{params[:full_name]}", :body => erb(:email)
  redirect ENV['REDIRECT_URL'] || 'http://localhost:4000/thank_you'
end
