module Explorer
  class Node
    class DataMatch
      def initialize(data, explorer_data: )
        @explorer_data = explorer_data
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

      def display_all
        # @data['lines'].to_s
        # ss = @data['lines']['text'].chomp.split(@explorer_data)
        ss = @data['lines']['text'].split(@explorer_data[:search_term])
        "#{(ss[0...-1].map { _1 + red(@explorer_data[:search_term]) } + [ss[-1]]).join}".chomp
        # "#{ss[0...-1].map { _1 + @explorer_data }} + #{ss[-1])}".chomp

        # "#{ss[0]}#{red(@explorer_data)}#{ss[1..].joins}"
        # "#{ss[0]}#{red(@explorer_data)}#{ss[1..].empty? ? "" : ss[1..].join}"
        # "#{@explorer_data}#{red(@data['lines']['text'].chomp)}"
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
=begin
      def initialize(data, )
        @data = data
      end
=end

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
end
