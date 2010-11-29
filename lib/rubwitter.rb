module Rubwitter
require "twitter_utils"
require "utils"
include Twitter_utils
include Rubwitter_utils

	
public
def Rubwitter.isNumeric?(string_to_check)
	begin
		Float(string_to_check)
	rescue 
		return false
	else
		return true
	end
end
def Rubwitter.start_app()
	set_browser()
	set_twitter_data()
		
	command = "quit1"
	quit_string_array = ["quit", ":q", "q"]
	#set black background and send escape sequence to clear the screen
	print "\e[33;40m"
	print "\e[2J"
	#do not forget to reverse each @timeline. This is done because most recent tweet should be shown at the bottom and have #==1
	@timeline = JSON.parse(@client.home_timeline().to_json).reverse
	until quit_string_array.include?(command) do
		printf "\e[0;32;40m"
		print "command> "
		command_raw = gets.chomp
		@command_splitted = command_raw.split(' ')
		command = @command_splitted[0]
		case command
		when "twit", "t", "tweet" 
			twit = ""
			if @command_splitted[1] == nil
				print "Enter twit message: "
				twit = gets.chomp
				next if twit == "" 
			else 
				@command_splitted[1..-1].each {|e| twit = twit << " " << e
				}
			end
			@client.update(twit)
		when "timeline", "tl", "u"
			print "Getting timeline...\n"
			#do not forget to reverse each @timeline. This is done because most recent tweet should be shown at the bottom and have #==1
			@timeline = JSON.parse(@client.home_timeline().to_json).reverse
			print "\e[2J"
			show_timeline(@timeline)
		when "retweet", "re", "r"
			retweet_number = nil
			if isNumeric?(@command_splitted[1]) and @command_splitted[1].to_i <= @timeline.count
				retweet_number = @command_splitted[1].to_i
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


			response_value = @client.retweet(@timeline[@timeline.count-retweet_number.to_i]['id'].to_i) if retweet_number != nil
			if response_value["errors"] == nil
				puts "Tweet ##{retweet_number} was retweeted"
			else
				puts "Error occurred: #{response_value["errors"]}"
			end

		when "help", "h"
			show_help()
		when "browse", "br", "b"
			twit_number = nil
			page_to_open = nil
			if @command_splitted[1] == nil or @command_splitted[1].to_i == 0 or @command_splitted[1].to_i > @timeline.count
				
				print "Specify # of tweet to open in browser\n"
				twit_number = gets.chomp.to_i
				if twit_number == 0 or twit_number > @timeline.count
					puts "You entered invalid tweet number"
					next	
				end
			else twit_number = @command_splitted[1].to_i
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
			if @command_splitted[1] != nil
					@command_splitted[1..-1].each { |e|
						search_string = search_string << " " << e
					}
				else
					printf "Specify search string: \n"
					search_string = gets.chomp
					next if search_string == ""
			end
			#do not forget to reverse each @timeline. This is done because most recent tweet should be shown at the bottom and have sequence number==1
			@timeline = JSON.parse(@client.search(search_string).to_json)["results"].reverse
			show_timeline(@timeline, true)
		when "show", "sh"
			twitter_username_to_show = format_single_argument("Specify twitter username to show: ", @command_splitted[1])
			next if twitter_username_to_show == ""	
			options = Hash.new
			options[:screen_name] = twitter_username_to_show
			process_response_value("user_timeline", options)
		when "friend", "fr"
			process_friend_unfriend_response(true)
		when "ufriend", "ufr"
			process_friend_unfriend_response(false)
		end	


	end	

	end

end
