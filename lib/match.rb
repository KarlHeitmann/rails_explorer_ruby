require_relative 'data_match'

class Match < DataMatch
  def to_s
    s = <<-STRING
    \tpath: #{@data['path']}
    \tlines: #{@data['lines']}
    \tline_number: #{@data['line_number']}
    \tabsolute_offset: #{@data['absolute_offset']}
    \tsubmatches: #{@data['submatches']}
    STRING
    "#{@data}\n\t#{@data.keys}"
    s
  end
end


