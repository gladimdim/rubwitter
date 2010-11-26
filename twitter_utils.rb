module Twitter_utils

def show_timeline(list_to_show, from_search = false)
		count = list_to_show.count
		list_to_show.each { |e| 
			time = Time.parse(e['created_at']).strftime("%m/%d/%y at %H:%M")
			date_from_response = Time.parse(e["created_at"]).strftime("%m/%d/%y")
			current_date_time = Time.parse(Time.now.to_s).strftime("%m/%d/%y")
			date_time_to_show = ""
			if date_from_response.eql? current_date_time
				date_time_to_show = Time.parse(e['created_at']).strftime("at %H:%M")
			else
				date_time_to_show = "#{time}"
			end
			puts "********************"
			printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, e['user']['screen_name'], date_time_to_show, e['text'] if !from_search
			printf "%s\e[37;40m %-20s %-17s:\e[33;40m %-30s\n", count.to_s, e['from_user'], date_time_to_show, e['text'] if from_search
			
			count = count - 1

		}
		puts "********************"
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

end
