class Node
  class DataMatch
    def initialize(data)
      @data = data
    end

    #   def to_s
    #     "#{@data}"
    #   end
  end

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
      loop do
        choices = [
          { name: 'View self', value: 1 },
          { name: 'View path', value: 2 },
          { name: 'View lines', value: 3 },
          { name: 'Quit', value: 'q' }
        ]
        option = prompt.enum_select('Select an option', choices)
        case option
        when 1
          puts inspect
        when 2
          puts @data['path']['text']
          # puts self.inspect
        when 3
          puts @data['lines'] # TODO: Highlight searched term in lines, use ttytoolkit
          # puts self.inspect
        else
          break
        end
      end
    end
    #   def to_s
    #     s = <<-STRING
    #     \tMATCH
    #     \t\tpath: #{@data['path']}
    #     \t\tlines: #{@data['lines']}
    #     \t\tline_number: #{@data['line_number']}
    #     \t\tabsolute_offset: #{@data['absolute_offset']}
    #     \t\tsubmatches: #{@data['submatches']}
    #     STRING
    #     # "type MATCH: #{@data}\n\t#{@data.keys}"
    #     "type MATCH: #{@data.keys}"
    #     s
    #   end
  end
  # Begin
  # properties:
  # path
  class Begin < DataMatch
    def initialize(data)
      @data = data
    end

    def file_name
      @data['path']['text']
    end

=begin
    def to_s
      # "type BEGIN: #{@data}\n\t#{@data.keys}"
      "type BEGIN: #{@data.keys}"
      "\tpath: #{@data['path']}"
    end
=end
  end

  # End
  # properties:
  # path
  # binary_offset
  # stats
  class End < DataMatch
=begin
    def to_s
      s = <<-STRING
      \tpath: #{@data['path']}
      \tbinary_offset: #{@data['binary_offset']}
      \tstats: #{@data['stats']}
      STRING
      # "type END: #{@data}\n\t#{@data.keys}"
      "type END: #{@data.keys}"
      s
    end
=end
  end

  # Summary
  class Summary < DataMatch
=begin
    def to_s
      s = <<-STRING
      \telapsed_total: #{@data['elapsed_total']}
      \tstats: #{@data['stats']}
      STRING
      # "type SUMMARY: #{@data}\n\t#{@data.keys}"
      "type SUMMARY: #{@data.keys}"
      s
    end
=end
  end

end
