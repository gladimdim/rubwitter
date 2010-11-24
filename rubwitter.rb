#!/usr/bin/env ruby
module Rubwitter
require "twitter_oauth"
require "yaml"
require "open3"
def Rubwitter.show_timeline(list_to_show, from_search = false)
		count = list_to_show.count
		list_to_show.each { |e| 
			#puts e
			time = Time.parse(e['created_at']).strftime("%m/%d%y")# at %H:%M")
			current_date_time = Time.now
			date_time_to_show = ""
			if time.eql? current_date_time
				date_time_to_show = Time.parse(e['created_at']).strftime("at %H:%M")
			else
				date_time_to_show = time
			end
			puts "********************"
			printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, e['user']['screen_name'], date_time_to_show, e['text'] if !from_search
			printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, e['from_user'], date_time_to_show, e['text'] if from_search
			
			count = count - 1

		}
		puts "********************"
end

def Rubwitter.isNumeric(string_to_check)
	begin
		Float(string_to_check)
	rescue 
		return false
	else
		return true
	end
end

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
	command_raw = gets.chomp
	command_splitted = command_raw.split(' ')
	command = command_splitted[0]
	case command
	when "twit", "t" 
		print "Enter twit message: "
		twit = gets.chomp
		client.update(twit) if twit != nil
	when "timeline", "tl", "u"
		print "Getting timeline...\n"
		@timeline = JSON.parse(client.home_timeline().to_json).reverse
		print "\e[2J"
		Rubwitter.show_timeline(@timeline)
	when "retweet", "re", "r"
		retweet_number = nil
		if isNumeric(command_splitted[1]) and command_splitted[1].to_i <= @timeline.count
			retweet_number = command_splitted[1].to_i
		else
			puts "Specify # of tweet to retweet: "
			value = gets.chomp
			if not isNumeric(value) or value.to_i > @timeline.count
				puts "You must enter valid number"
				next
			else
				retweet_number = value
			end
		end


		response_value = client.retweet(@timeline[@timeline.count-retweet_number.to_i]['id'].to_i) if retweet_number != nil
		if response_value["errors"] == nil
			puts "Tweet ##{retweet_number} was retweeted"
		else
			puts "Error occurred: #{response_value["errors"]}"
		end

	when "help", "h"
		print "Available commands: \n"
		printf "%-30s %s", "timeline, tl, u", "Update your home timeline\n"
		printf "%-30s %s", "t, tweet", "Write new tweet\n"
		printf "%-30s %s", "retweet, re, r", "Retweet tweet\n"
		printf "%-30s %s", "help, h", "Display this help\n"
		printf "%-30s %s", "quit, q, :q", "Quit application\n"
		printf "%-30s %s", "browser, b, br", "Open link for specified #tweet in browser\n"
	when "browse", "br", "b"
		twit_number = nil
		page_to_open = nil
		if command_splitted[1] == nil or command_splitted[1].to_i == 0 or command_splitted[1].to_i > @timeline.count
			
			print "Specify # of tweet to open in browser\n"
			twit_number = gets.chomp.to_i
			if twit_number == 0 or twit_number > @timeline.count
				puts "You entered invalid tweet number"
				next	
			end
		else twit_number = command_splitted[1].to_i
		end
		@timeline[@timeline.count-twit_number.to_i]['text'].split().each { |splitted_twit| page_to_open = splitted_twit if splitted_twit.include?("http://") }

		if page_to_open != nil
			#value = system("#{ENV['BROWSER']} #{page_to_open} >> /dev/null")
			Open3.popen3("#{ENV['BROWSER']} #{page_to_open}") # {|stdin, stdout, stderr| puts stdout}
		else
			puts "No links found in tweet ##{twit_number}"
		end
	when "s", "search", "se"
		search_string = "" 
		if command_splitted[1] != nil
				command_splitted[1..-1].each { |e|
					search_string = search_string << " " << e
				}
			else
				printf "Specify search string: \n"
				search_string = gets.chomp
				next if search_string == ""
		end
		
		@timeline = JSON.parse(client.search(search_string).to_json)["results"]
		Rubwitter.show_timeline(@timeline, true)
	end	
end	

end


