require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'json'
require 'yaml'

include ERB::Util

configure do
	get('/css/styles.css') { scss :styles }

	LETTERS = Array('a'..'z') + Array('A'..'Z') + Array(1..9)

	def generate_url
		Array.new(8) { LETTERS.sample }.join
	end

	enable :show_exceptions, :sessions, :logging
	set :app_file, 'main.rb'
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
	@path = :'DynoPop'
	unless params.nil?
		@dyno_link		= params[:byte]
		@dyno_origin	= params[:link]
		params.clear
	end
	erb :home
end

get '/:url' do
	@dyno_link = params[:url]

	data = File.open('bytes.yml', "r") { |file|
		YAML.load(file)
	}
	

	url_exists = Array.new
	
	data[:data].each {|byte|
		if byte[:byte] == @dyno_link
			byte[:clicks] += 1
			url_exists.push(byte)
		end
	}
	
	File.open('bytes.yml', "w") { |file|
		YAML.dump(data, file)
	}

	if url_exists.first.nil?
		status 404
		redirect to not_found
	end
	
	@dyno_origin = url_exists.first[:url]
	
	status 302
	redirect to @dyno_origin
end

post '/links' do
	url = params[:link].chomp('/').downcase
	data = Hash.new

	data = File.open('bytes.yml', "r+") { |file|
		YAML.load(file)
	}

	url_exists = Array.new
	
	data[:data].each {|byte|
		url_exists.push(byte) if byte[:url] == url
	}

	# Get the short link saved in the url_exists array
	url_exists = url_exists.first

	unless url.match(/^https:\/\/|www.|http:\/\//)
		flash[:warning] = 'Could not shorten link. That is not a valid web address.'
		redirect to '/'
	end

	unless url_exists.nil?
		@dyno_link = url_exists[:byte]
		flash[:notice] = 'Short link already exists. Find the link below.'
	else
		@dyno_link = generate_url
		new_byte = { url: url, byte: @dyno_link, clicks: 0, created_at: Time.now.to_i }
		
		data[:data].push(new_byte)
		
		File.open('bytes.yml', "r+") { |file|
			YAML.dump(data, file)
		}
		flash[:success] = 'New link created.'
	end

	redirect to("/?byte=#{@dyno_link}&link=#{url_encode(url)}")
end

not_found do
	@path = :'oops! page not found'
	status 404
	erb :'404'
end