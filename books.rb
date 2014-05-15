require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'json/ext'

get '/initialize/' do
   conn = Mongo::Connection.new
    db     = conn['test']
    coll   = db['books']
    coll.remove()
    coll.insert({:title => "One Hundred Years of Solitude", :author => "Gabriel Garcia Marquez", 
    	:url => "https://thewitcontinuum.files.wordpress.com/2012/01/one_hundred_years_of_solitude.jpg",
    	:description => "Very difficult to read and very depressing story about a family. The time goes, children grow..."})
    coll.insert({:title => "Ender's Game", :author => "Orson Scott Card", 
    	:url => "http://www.hatrack.com/osc/books/endersgame/endersgame.jpg",
    	:description => "Wonderful science fiction about a person growing up, about solitude and strength."})
    coll.insert({:title => "Dandelion Wine", :author => "Ray Bradbury", 
    	:url => "http://collider.com/wp-content/uploads/dandelion-wine-book-cover.jpg",
    	:description =>"Beautiful book about life, happiness, childhood. Very bright. Delightful."})
    coll.insert({:title => "To Kill a Mockingbird", :author => "Harper Lee", 
    	:url => "http://deepsouthmag.com/wp-content/uploads/2013/04/mockingbird.jpg",
    	:description =>"This is a very interesting book about people and humanity of every person.",
    	:comments => [{:name => "Ann", :comment => "A good book."}]}) 
end

get '/books/' do
	conn = Mongo::Connection.new
    db = conn['test']
    coll = db['books']
	@books = []
	coll.find.each {|doc| @books<<doc }
	erb :book
end

get '/books/:id' do

	conn = Mongo::Connection.new
    db     = conn['test']
    coll   = db['books']
	@books = []
	coll.find.each {|doc| @books<<doc }

	@book = @books.select {|b| b['_id'].to_s == params[:id]}.first
	
	erb :singleBook
end

get '/newBook' do
  erb :newBook
end
 
post '/newBook/?' do
	content_type :json
	conn = Mongo::Connection.new
    db = conn['test']
    coll = db['books']
	@books = []
	coll.insert params
	redirect "/books/"
 end

get '/comment/:id' do
	conn = Mongo::Connection.new
    db     = conn['test']
    coll   = db['books']
	@books = []
	coll.find.each {|doc| @books<<doc }

	@book = @books.select {|b| b['_id'].to_s == params[:id]}.first
	erb :comment
end

post '/comment/:id/?' do
	content_type :json
	conn = Mongo::Connection.new
    db = conn['test']
    coll = db['books']

    oneComment = {:name => params[:name], :comment => params[:comment]} 
    coll.update({:_id => BSON::ObjectId.from_string(params[:id])}, {"$push" => {:comments => oneComment}}) 
	redirect "/books/" + params[:id]
end