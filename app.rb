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

migration "add page url to submissions" do
  database.alter_table :submissions do
    add_column :page_url, :text
  end
end

class Submission < Sequel::Model; end

get '/wakeup' do
  puts "Waking up..."
  accepted_hosts.each do |h|
    response['Access-Control-Allow-Origin'] = h if request.referrer.start_with?(h)
  end
  status 200
  body ""
end

post '/contact' do
  puts "Contact submission:"
  puts params
  if params[:catch_me].nil? || params[:catch_me] == ""
    Submission.create(:name => params[:full_name], :email => params[:email], :message => params[:message], :page_url => params[:page_url])
    Pony.mail :to => "support@alfajango.com", :from => params[:email], :subject => "[AJ Contact Form] Submission from #{params[:full_name]}", :body => erb(:email)
  else
    puts "Catch-me filled out. Skipping save-and-send."
  end
  redirect ENV['REDIRECT_URL'] || 'http://localhost:3000/thank_you'
end

def accepted_hosts
  %w(http://localhost:3000 http://www.alfajango.com)
end
