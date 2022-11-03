require_relative 'data_match'

# Match
# properties
# path
# lines
# line_number
# absolute_offset
# submatches
class Match < DataMatch
  def action
    prompt = TTY::Prompt.new
    while true
      choices = [
        { name: 'View self', value: 1 },
        { name: 'View path', value: 2 },
        { name: 'View lines', value: 3 },
        { name: 'Quit', value: 'q' }
      ]
      option = prompt.enum_select('Select an option', choices)
      if option == 1
        puts self.inspect
      elsif option == 2
        puts @data['path']['text']
        # puts self.inspect
      elsif option == 3
        puts @data['lines'] # TODO: Highlight searched term in lines, use ttytoolkit
        # puts self.inspect
      else
        break
      end
    end

  end
=begin
  def to_s
    s = <<-STRING
    \tMATCH
    \t\tpath: #{@data['path']}
    \t\tlines: #{@data['lines']}
    \t\tline_number: #{@data['line_number']}
    \t\tabsolute_offset: #{@data['absolute_offset']}
    \t\tsubmatches: #{@data['submatches']}
    STRING
    # "type MATCH: #{@data}\n\t#{@data.keys}"
    "type MATCH: #{@data.keys}"
    s
  end
=end
end


