# frozen_string_literal: false

require_relative 'node/data'
# require_relative 'explorer/node/data'
# Node models a match from rg --json
module Explorer
  class Node
    # attr_writer :span_lines
    attr_accessor :span_lines

    def initialize(matches, explorer_data: )
      @matches = []
      @explorer_data = explorer_data
      @span_lines = explorer_data[:spanlines].to_i

      matches.each do |match|
        case match['type']
        when 'begin'
          @begin_data = Begin.new(match['data'], explorer_data: explorer_data)
        when 'context'
          @matches << Context.new(match['data'], explorer_data: explorer_data)
        when 'match'
          @matches << Match.new(match['data'], explorer_data: explorer_data)
        when 'end'
          @end_data = End.new(match['data'], explorer_data: explorer_data)
        end
      end
    end

    def verbose
      <<-VERBOSE
      #{@begin_data.file_name}
      VERBOSE
    end

    # @return [String]
    def name_file
      # "@begin_data = #{@begin_data.inspect}\n@matches = #{@matches.inspect}\n@end_data = #{@end_data.inspect}"
      # @begin_data['path']['text']
      @begin_data.file_name
    end

    # @return [Integer]
    def matches_count
      @end_data.matches
    end

    def matches_iterative(ms)
      # if there is no instance_of?(Match) inside block passed to #index, #index will return nil
      # next_array = @matches[i_match+1..]

      i_match = ms.index { _1.instance_of?(Match)}
      if i_match.nil?
        return ''
      else
        ms[(i_match - @span_lines)..(i_match + @span_lines)].reduce('') { "#{_1}#{_2.display_all}" } + ('-' * 10) + "\n" +  matches_iterative(ms[i_match+1..])
      end
    end

    # @return [String]
    def matches # TODO: change name for a better thing, node_details? this is a wrapper for matches_iterative method above
      # i_match = @matches.index { _1.class == Match} # TODO: maybe put here a submenu with further action to do with submatches, like iterate over submatches, or pass another filter

      temp = matches_iterative(@matches)
      temp
    end

    def summary
      # 'PENDING'
      to_s
    end

    def action
      prompt = TTY::Prompt.new
      loop do
        choices = [
          { name: 'View name of the file', value: 1 },
          { name: 'View matches', value: 2 },
          { name: 'Quit', value: 'q' }
        ]
        option = prompt.enum_select('Select an option', choices)
        puts "option: #{option.inspect}"
        case option
        when 1
          puts @begin_data.file_name
        when 2
          @matches.each(&:action)
        else
          break
        end
      end
    end

    def dataKlass(t, _d)
      case t
      when 'begin'
        Begin
      when 'match'
        Match
      when 'end'
        End
      when 'summary'
        Summary
      else
        puts t
        1 / 0
      end
    end

    def self.parse(match)
      new(match)
    end

=begin
    def to_s
      # "type: #{@raw_data.class}\n#{@raw_data}\n\n"
      # matches_string = @matches.reduce("---\n") { _1 + "#{_2}\n--------\n\t" }
      matches_string = @matches.reduce("\n") { _1 + "#{_2}\n" }
      # "node\n\tbegin_data: #{@begin_data}\n\tmatches (#{@matches.count}): #{@matches}\n\tend_data#{@end_data}\n"
      "node\n\tbegin_data: #{@begin_data}\n\tMATCHES (#{@matches.count}): \n#{matches_string}\n\tend_data#{@end_data}\n"
    end
=end
  end
end


