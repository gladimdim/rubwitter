module Twitter_utils
       
require "uri"
require "yajl/http_stream"

def stream_user(username, password,filter_options)
	@stream_count = 0
	user_status_url = URI.parse("http://#{username}:#{password}@stream.twitter.com/1/statuses/filter.json?#{filter_options}")
	Yajl::HttpStream.get(user_status_url, :symbolize_keys => true) do | status| 
		unless status.has_key?(:delete)
			@stream_count = @stream_count + 1
			#puts "#{status[:user][:screen_name]}"
			#puts "#{status[:text]}"
			show_timeline(JSON.parse(status.to_json()), false, true)
		end
	end
end

def process_filter_follow_options()
	# @filter_stream_follow_options contains user screenames separated by ',' character. But we need to cut off "track=" leading characters. Thaty's why we call sequence of splits:
	if @filter_stream_follow_options
		filter_stream_follow_options_split = @filter_stream_follow_options.split('=')[1].split(',')
	filter_stream_follow_options_split.each do |follow_screen_names|
		username_id = @client.show(follow_screen_names)["id"]
		next if username_id == nil
		if @filter_stream_follow_options_ids.eql?("follow=")
			@filter_stream_follow_options_ids << username_id.to_s
		else
			@filter_stream_follow_options_ids << "," << username_id.to_s 
		end
	end
	end
end
def show_timeline(list_to_show, from_search = false, from_stream=false)
		count = "" 
		count = list_to_show.count if not from_stream
		if not from_stream
			list_to_show.each { |e|
			show_tweet(e, count, from_search)	
			count = count - 1

			} 
		else
			show_tweet(list_to_show, @stream_count, from_search) 
		end
		puts "********************"
end

def show_tweet(tweet_to_show, count, from_search=false )
	time = Time.parse(tweet_to_show['created_at']).strftime("%m/%d/%y at %H:%M")
	date_from_response = Time.parse(tweet_to_show['created_at']).strftime("%m/%d/%y")
	current_date_time = Time.parse(Time.now.to_s).strftime("%m/%d/%y")
	date_time_to_show = ""
	if date_from_response.eql? current_date_time
		date_time_to_show = Time.parse(tweet_to_show['created_at']).strftime("at %H:%M")
	else
		date_time_to_show = "#{time}"
	end
	puts "********************"

	if from_search
		username_to_show=tweet_to_show['from_user']
	else
		username_to_show=tweet_to_show['user']['screen_name']
	end

	printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, username_to_show, date_time_to_show, tweet_to_show['text']
#	printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, tweet_to_show['from_user'], date_time_to_show, tweet_to_show['text'] if from_search

end


def format_single_argument(question_to_ask, command_splitted)
	if command_splitted == nil
		puts question_to_ask 
		single_argument = gets.chomp
		return single_argument
	else
		return command_splitted
	end
end	
def process_response_value(method_name, options={})
		response_value = @client.send method_name, options
		begin
			error = response_value["error"]
		rescue
			@timeline = response_value.reverse
			show_timeline(@timeline)
		else
			puts "Error occured: #{response_value["error"]}"
		end
		
end

def process_friend_unfriend_response(friend)
	string_follow_unfollow = "friend"
	string_follow_unfollow.insert(0, "un") if not friend
	if friend
		method_friend_unfriend = "friend"
	else
		method_friend_unfriend = "unfriend"
	end
	twitter_friend = format_single_argument("Specify twitter username to #{string_follow_unfollow}: ", @command_splitted[1])
	return if twitter_friend == ""	
	response_value = @client.send string_follow_unfollow, twitter_friend
	if response_value["error"] == nil
		puts "You #{string_follow_unfollow}ed #{twitter_friend}"
	else
		puts "Error occurred:#{response_value["error"]}"
	end


end

end
