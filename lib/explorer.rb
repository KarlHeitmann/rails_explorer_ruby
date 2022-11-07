require_relative 'explorer/node'

module Explorer
  class Nodes
    def self.tty_screen_width
      # puts "bla bla bla"
      TTY::Screen.columns
    end

    def screen_width
      @screen_width ||= self.class.tty_screen_width
    end

    def initialize(lines, autopilot=false)
      grouped_lines = []
      aux = []
      lines.each do |line_string|
        line = JSON.parse line_string
        case line['type']
        when 'begin'
          aux << line
        when 'match'
          aux << line
        when 'end'
          aux << line
          grouped_lines << aux
          aux = []
        when 'summary'
          # @summary = Summary.new(line['data'])
          @summary = line['data']
        else
          # puts line
          1 / 0
        end
      end
      @nodes = grouped_lines.map { Node.new(_1) }
      # @columns = TTY::Screen.columns
    end

    def summary_box
      text_to_display = ''
      choices = []
      @nodes.each_with_index do |node, i|
        text_to_display << node.name_file << "\n"
        # choices << { name: node.name_file, value: i + 1}
        choices << { name: node.name_file, value: i + 0}
      end
      choices << { name: 'Quit', value: 'q' }
      box = TTY::Box.frame(top: 0, width: 30, height: choices.size + 2) { text_to_display }
      # { choices: choices, box: box }
      [ choices, box ]
    end

    def autopilot
      choices, box = summary_box
      # puts screen_width
      max_height = choices.size
      detail = TTY::Box.frame(top: 0, left: screen_width - 30, width: 30, height: max_height + 2) { "" }
      # detail = TTY::Box.frame(top: 0, left: screen_width - 30, width: 30, height: max_height + 2) { "" }
      # detail = TTY::Box.frame(top: 0, left: screen_width - 30, width: 30, height: 10) { "" }
      # detail = TTY::Box.frame(top: 0, left: screen_width - 30, width: 30, height: 10) { "" }
      # detail = TTY::Box.frame(top: 0, left: screen_width - 30, width: 30, height: 10) { "" }
      loop do
        clear_screen
        # puts "choices.size = #{choices.size}\tmax_height = #{max_height}"
        print box
        print detail
        puts
        prompt = TTY::Prompt.new
        option = prompt.enum_select('Select an option', choices)  
        break if option == 'q'
        text_detail = @nodes[option].matches(screen_width)
        max_height = [choices.size, text_detail.count("\n") - 1].max
        # detail = TTY::Box.frame(top: 0, left: @columns - 30, width: 30, height: 10) { @nodes[option].name_file }
        # detail = TTY::Box.frame(top: 0, left: @columns - 30, width: 30, height: 10) { @nodes[option].summary }
        # detail = TTY::Box.frame(top: 0, left: 31, width: screen_width - 32) { @nodes[option].inspect }
        detail = TTY::Box.frame(top: 0, left: 31, width: screen_width - 32, height: max_height + 2) { text_detail }
        # puts @nodes[option].inspect
=begin
        clear_screen
        print box
        print detail
        gets
        break
=end
        # detail = TTY::Box.frame(top: 0, left: @columns - 30, width: 30, height: 10) { @nodes[option].action }
      end
    end

    def menu
      prompt = TTY::Prompt.new
      box = TTY::Box.frame(width: 30, height: 10) do
        "Drawin a box in terminal emulator"
      end
      loop do
        choices = [
          { name: 'View names of files', value: 1 },
          { name: 'View summary', value: 2 },
          { name: 'Take action', value: 3 },
          { name: 'Quit', value: 'q' }
        ]
        option = prompt.enum_select('Select an option', choices)
        # puts "option: #{option.inspect}"
        case option
        when 1
          # puts @nodes.reduce('') { _1 + _2.to_s }
          @nodes.each do |node|
            puts node.name_file
          end
        when 2
          @nodes.each do |node|
            puts node.summary
          end
        when 3
          @nodes.each do |node|
            puts node.action
          end
        else
          break
        end
      end
    end

    def to_s
      @nodes.reduce('') { _1 + _2.to_s }
    end
  end
end

