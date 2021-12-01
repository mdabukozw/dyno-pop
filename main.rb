require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'json'

include ERB::Util

configure do
	get('/css/styles.css') { scss :styles }

	LETTERS = Array('a'..'z') + Array('A'..'Z') + Array(1..9)

	def generate_url
		Array.new(8) { LETTERS.sample }.join
	end

	enable :show_exceptions, :sessions, :logging
end

helpers do
	def css(*stylesheets)
		stylesheets.map do |stylesheet|
			"<link href=\"/css/#{stylesheet.downcase}.css\" type='text/css' media='screen, projection' rel='stylesheet'/>"
		end.join
	end

	def less(*stylesheets)
		stylesheets.map do |stylesheet|
			"<link href=\"/css/#{stylesheet.downcase}.less\" media='screen, projection' rel='stylesheet/less'/>"
		end.join
	end

	def current?(path='/')
		(request.path == path || request.path == path+'/') ? :'current' : nil
	end
end

get '/' do
	unless params.nil?
		@dyno_link		= params[:byte]
		@dyno_address	= params[:link]
		params.clear
	end
	erb :url_new
end

get '/:url' do
	@dyno_link = params[:url]

	file = File.new('bytes.json', 'r+')
	json = File.read(file)
	data = JSON.parse(json)
	@dyno_address = data['data'][@dyno_link]
	file.close
	
	redirect to @dyno_address
end

get '/url' do
	params.inspect
end

post '/links' do
	url = params[:link].chomp('/').downcase
	data = Hash.new

	file = File.new('bytes.json', 'r+')
	json = File.read(file)
	data = JSON.parse(json)

	if data['data'].values.include?(url)
		@dyno_link = data['data'].key(url)
		flash[:notice] = 'Short link already exists. Find the link below'
	else
		# if !File::exists?('bytes.json')
		# 	file = File.new('bytes.json', 'w+')
		# 	@dyno_link = generate_url
		# 	data[@dyno_link] = url
		# 	data = {
		# 		data: data
		# 	}
		# 	File.write('bytes.json', JSON.pretty_generate(data))
		# 	file.close
			
		# 	flash[:success] = 'New URL created'
		# else
		@dyno_link = generate_url
		
		data['data'][@dyno_link] = url
		
		File.write('bytes.json', JSON.pretty_generate(data))
		file.close
		flash[:success] = 'New link created'
		# end
	end

	@dyno_address = url
	redirect to("/?byte=#{@dyno_link}&link=#{url_encode(url)}")
end