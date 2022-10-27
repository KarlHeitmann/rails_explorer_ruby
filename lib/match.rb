require_relative 'data_match'

# Match
# properties
# path
# lines
# line_number
# absolute_offset
# submatches
class Match < DataMatch
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
end


