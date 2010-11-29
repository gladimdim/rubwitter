module Rubwitter_utils

def set_browser
unless ENV["BROWSER"] != nil
	puts "Your $BROWSER variable is not set. Do \"export $BROWSER=[path to your browser exec file]\""
	puts "You can also specify it manually: "
	browser = gets.chomp
	ENV["BROWSER"] = browser if browser != ""
end
end

def set_twitter_data
	twitter_auth_data_file = "#{ENV['HOME']}/.rubwitter_auth"

	set_initial_twitter(twitter_auth_data_file)
	set_authorized_twitter(twitter_auth_data_file)
end

def show_help
	print "Available commands: \n"
	printf "%-30s %s", "timeline, tl, u", "Update your home timeline\n"
	printf "%-30s %s", "t, tweet, twit", "Write new tweet\n"
	printf "%-30s %s", "retweet, re, r", "Retweet tweet. You can specify # of tweet as optional parameter\n"
	printf "%-30s %s", "help, h", "Display this help\n"
	printf "%-30s %s", "quit, q, :q", "Quit application\n"
	printf "%-30s %s", "browser, b, br", "Open link for specified #tweet in browser. You can specify # of tweet as optional parameter\n"
	printf "%-30s %s", "search, se, s", "Search for tweets. Second argument is parsed as search string\n"

end


private


def set_authorized_twitter(twitter_auth_data_file)
	auth = YAML.load(File.open(twitter_auth_data_file))
	@client = TwitterOAuth::Client.new(:consumer_key => '4hzw6bvfdlcqzJH1jSfgw',
					  :consumer_secret => 'vPJKDeiAEcXiQoBvHr8pfRNdFPl3BbY72w7ufCsk',
					  :token => auth["token"],
					  :secret => auth["token_secret"]
	)end

def set_initial_twitter(twitter_auth_data_file)
	unless File.exists?(twitter_auth_data_file)
		@client = TwitterOAuth::Client.new(:consumer_key => '4hzw6bvfdlcqzJH1jSfgw',
						  :consumer_secret => 'vPJKDeiAEcXiQoBvHr8pfRNdFPl3BbY72w7ufCsk'
		)
		request_token = @client.request_token()
		puts "Your browser now will be opened. You will be redirected to twitter site. 
		You need to give authorization for this application. Click ALLOW button in browser. 
		Then copy returned by twitter 7 digin PIN number. Do not close browser."
		puts "Press ENTER key to open browser."
		puts "#{ENV['BROWSER']} will be used to open twitter site"
		gets
		value = system("#{ENV['BROWSER']} #{request_token.authorize_url}")
		puts "Enter returned by twitter 7 digit PIN: "
		pin = gets.chomp
		puts "You may now close browser"
		access_token = @client.authorize(
			request_token.token,
			request_token.secret,
			:oauth_verifier => pin	
		)
		if @client.authorized? then
			printf "%40s\n", "Thanks for using Rubwitter. It was authorized at twitter site. You may now start using it."
			auth = {} 
			auth["About"] = "This file contains authorization keys for rubwitter application"
			auth["token"] = access_token.token
			auth["token_secret"] = access_token.secret
			File.open(twitter_auth_data_file, "w") { |f| YAML.dump(auth, f) }
		end

	end

end

end

