#!/usr/bin/env ruby

require "twitter_oauth"
require "yaml"
twitter_auth_data_file = "#{ENV['HOME']}/.rubwitter_auth"

unless File.exists?(twitter_auth_data_file)

	client = TwitterOAuth::Client.new(:consumer_key => '4hzw6bvfdlcqzJH1jSfgw',
					  :consumer_secret => 'vPJKDeiAEcXiQoBvHr8pfRNdFPl3BbY72w7ufCsk'
	)

	request_token = client.request_token()
	puts "Your browser now will be opened. You will be redirected to twitter site. 
	You need to give authorization for this application. Click ALLOW button in browser. 
	Then copy returned by twitter 7 digin PIN number. Do not close browser."
	puts "Press ENTER key to open browser."
	puts ENV['BROWSER']
	gets
	value = system("#{ENV['BROWSER']} #{request_token.authorize_url}")
	puts "Enter returned by twitter 7 digit PIN: "
	pin = gets.chomp
	puts "You may now close browser"
	access_token = client.authorize(
		request_token.token,
		request_token.secret,
		:oauth_verifier => pin	
	)
	if client.authorized? then
		printf "%40s\n", "Thanks for using Rubwitter. It was authorized at twitter site. You may now start using it."
		auth = {} 
		auth["About"] = "This file contains authorization keys for rubwitter application"
		auth["token"] = access_token.token
		auth["token_secret"] = access_token.secret
		File.open(twitter_auth_data_file, "w") { |f| YAML.dump(auth, f) }
	end

end

auth = YAML.load(File.open(twitter_auth_data_file))
client = TwitterOAuth::Client.new(:consumer_key => '4hzw6bvfdlcqzJH1jSfgw',
				  :consumer_secret => 'vPJKDeiAEcXiQoBvHr8pfRNdFPl3BbY72w7ufCsk',
				  :token => auth["token"],
				  :secret => auth["token_secret"]
)

puts ENV['BROWSER'] if client.authorized?

command = "quit1"
#puts command == "quit1"
#until command.eql? "quit" or command.eql? ":q" do
quit_string_array = ["quit", ":q", "q"]
print "\e[33;40m"
print "\e[2J"
@timeline = JSON.parse(client.home_timeline().to_json).reverse
until quit_string_array.include?(command) do
	printf "\e[0;32;40m"
	print "command> "
	command = gets.chomp
	case command
	when "twit", "t" 
		print "Enter twit message: "
		twit = gets.chomp
		client.update(twit) if twit != nil
	when "timeline", "tl", "u"
		print "Getting timeline...\n"
		@timeline = JSON.parse(client.home_timeline().to_json).reverse
		print "\e[2J"
		count = @timeline.count
		@timeline.each { |e| 
			puts "********************"
			printf "%s\e[37;40m %-20s:\e[33;40m %-30s\n", count.to_s, e['user']['screen_name'], e['text'] 
			count = count - 1

		}
		puts "********************"
	when "retweet", "re", "r"
		print "Specify # of tweet to retweet: "
		retweet_number = gets.chomp
		client.retweet(@timeline[retweet_number.to_i]['id'].to_i)
	when "help", "h"
		print "Available commands: \n"
		printf "%-30s %s", "timeline, tl, u", "Update your home timeline\n"
		printf "%-30s %s", "t, tweet", "Write new tweet\n"
		printf "%-30s %s", "retweet, re, r", "Retweet tweet\n"
		printf "%-30s %s", "help, h", "Display this help\n"
		printf "%-30s %s", "quit, q, :q", "Quit application\n"
	end

		
end

