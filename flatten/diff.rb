diff -r -N rubymcofresh/optionparser.rb rubymcoedited/optionparser.rb
67d66
< 
120a120,124
>       @parser.on('-f', '--flatten', 'Flatten output') do |v|
>         @options[:flatten] = v
>       end
> 
> 
diff -r -N rubymcofresh/rpc/client.rb rubymcoedited/rpc/client.rb
44a45
> 	@flatten = initial_options[:flatten]
478a480
> 	 :flatten => @flatten,
diff -r -N rubymcofresh/rpc/helpers.rb rubymcoedited/rpc/helpers.rb
116d115
< 
129c128
<             [result].flatten.each do |r|
---
>             [result].flatten.sort_by { |hsh| hsh[:sender] }.each do |r|
133a133
> 		#puts sender
137c137
<                 result = r[:data]
---
>                 res = r[:data]
140,144c140,152
<                 case display
<                 when :ok
<                   if status == 0
<                     result_text << text_for_result(sender, status, message, result, ddl)
<                   end
---
> 		if flags[:flatten]
> 		   result_text << text_for_result_two(sender, status, message, res, ddl)
> 		else
>                    case display
>                    when :ok
>                      if status == 0
>                        result_text << text_for_result(sender, status, message, res, ddl)
>                      end
> 
>                    when :failed
>                      if status > 0
>                        result_text << text_for_result(sender, status, message, res, ddl)
>                      end
146,149c154,155
<                 when :failed
<                   if status > 0
<                     result_text << text_for_result(sender, status, message, result, ddl)
<                   end
---
>                    when :always
>                      result_text << text_for_result(sender, status, message, res, ddl)
151,155c157,158
<                 when :always
<                   result_text << text_for_result(sender, status, message, result, ddl)
< 
<                 when :flatten
<                   result_text << text_for_flattened_result(status, result)
---
>                    when :flatten
>                      result_text << text_for_result_two(sender, status, message, res, ddl)
157a161
> 	    end
235a240,313
>       # Return text representing a result
>       def self.text_for_result_two(sender, status, msg, result, ddl)
>         statusses = ["",
>                      colorize(:red, "Request Aborted"),
>                      colorize(:yellow, "Unknown Action"),
>                      colorize(:yellow, "Missing Request Data"),
>                      colorize(:yellow, "Invalid Request Data"),
>                      colorize(:red, "Unknown Request Status")]
> 
>         #result_text = "%-40s %s\n" % [sender, statusses[status]]
> 	result_text = ""
>         result_text << "   %s\n" % [colorize(:yellow, msg)] unless msg == "OK"
> 
>         # only print good data, ignore data that results from failure
>         if [0, 1].include?(status)
>           if result.is_a?(Hash)
>             # figure out the lengths of the display as strings, we'll use
>             # it later to correctly justify the output
>             lengths = result.keys.map do |k|
>               begin
>                 ddl[:output][k][:display_as].size
>               rescue
>                 k.to_s.size
>               end
>             end
> 
>             result.keys.each do |k|
>               # get all the output fields nicely lined up with a
>               # 3 space front padding
>               begin
>                 display_as = ddl[:output][k][:display_as]
> 		#result_text << display_as.to_s
> 		if display_as.to_s.eql?("status")
> 			next
> 		end
>               rescue
>                 display_as = k.to_s
>               end
> 
>               display_length = display_as.size
>               padding = lengths.max - display_length + 3
>               #result_text << " " * padding
> 
>               #result_text << "#{display_as}:"
> 
>               if [String, Numeric].include?(result[k].class)
>                 lines = result[k].to_s.split("\n")
> 
>                 if lines.empty?
>                   result_text << "\n"
>                 else
>                   lines.each_with_index do |line, i|
>                     #i == 0 ? padtxt = " " : padtxt = " " * (padding + display_length + 2)
> 
>                     padtxt = " " * (padding + display_length + 2)
>                     result_text << "#{padtxt}#{line}\n"
>                   end
>                 end
>               else
>                 padding = " " * (lengths.max + 5)
>                 result_text << " " << result[k].pretty_inspect.split("\n").join("\n" << padding) << "\n"
>               end
>             end
>           else
>             result_text << "\n\t" + result.pretty_inspect.split("\n").join("\n\t")
>           end
>         end
> 
>         result_text << "\n"
>         result_text
>       end
> 
> 
> 
diff -r -N rubymcofresh/rpc.rb rubymcoedited/rpc.rb
151c151,153
<       flatten = flags[:flatten] || false
---
>       flatten = @options[:flatten] rescue flatten = false
>       flatten = flags[:flatten] || flatten
> 
diff -r -N rubymcofresh/util.rb rubymcoedited/util.rb
159a160
> 	:flatten     => false,
