# frozen_string_literal: false

require_relative 'node/data'
# require_relative 'explorer/node/data'
# Node models a match from rg --json
module Explorer
  class Node
    def initialize(matches)
      @matches = []

      matches.each do |match|
        case match['type']
        when 'begin'
          @begin_data = Begin.new(match['data'])
        when 'match'
          @matches << Match.new(match['data'])
        when 'end'
          @end_data = End.new(match['data'])
        end
      end
    end

    def verbose
      <<-VERBOSE
      #{@begin_data.file_name}
      VERBOSE
    end

    def name_file
      # "@begin_data = #{@begin_data.inspect}\n@matches = #{@matches.inspect}\n@end_data = #{@end_data.inspect}"
      # @begin_data['path']['text']
      @begin_data.file_name
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


