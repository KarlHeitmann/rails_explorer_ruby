require_relative 'explorer/node'

module Explorer
  class IOUtils
    def getCmdData(cmd)
      io = IO.popen(cmd)
      data = io.read
      io.close
      # raise 'it failed!' unless $?.exitstatus == 0
      data
    end
  end

  class Nodes
    def self.tty_screen_width
      # puts "bla bla bla"
      TTY::Screen.columns
    end

    def screen_width
      @screen_width ||= self.class.tty_screen_width
    end

    def initialize(explorer_data:)
      # @autopilot = autopilot
      @io = IOUtils.new
      @explorer_data = explorer_data
      grouped_lines = []
      aux = []
      puts ":::::::"
      puts @explorer_data.inspect
      # 1/0
      lines = rg_launch
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
      @nodes = grouped_lines.map { Node.new(_1, explorer_data: explorer_data) }
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
      title = @explorer_data[:search_term]
      puts title
      box = TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: {top_left: title, bottom_right: "v1.0"}) { text_to_display }
      # box = TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: {top_left: "TITLE", bottom_right: "v1.0"}) { text_to_display }
      # box = TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: {top_left: @explorer_data[:search_term], bottom_right: "v1.0"}) { text_to_display }
      # { choices: choices, box: box }
      [ choices, box ]
    end

    def individual_action(option)
      complete_file_name = @nodes[option].name_file
      file_name = complete_file_name.split('/')[-1]
      if (file_name[0] == '_') and (file_name[-3..] == 'erb')
        clear_screen
        prompt = TTY::Prompt.new
        choices = [
          { name: file_name, value: 1 },
          { name: "Quite", value: 'q' },
        ]
        option = prompt.enum_select("====> Select an option for #{complete_file_name}", choices)  
        unless option == 'q'
=begin
          explorer_child_data = {
            search_term: "render.*#{file_name.split('.').first[1..]}",
            path: @explorer_data[:path]
          }
=end
          explorer_child_data = @explorer_data
          explorer_child_data[:search_term] = "render.*#{file_name.split('.').first[1..]}"
          explorer_child = Nodes.new(explorer_data: explorer_child_data)
          explorer_child.menu
        end
      end
    end

    def rg_launch
      # lines = io.getCmdData(cmd).split("\n")
      cmd = "rg #{@explorer_data[:search_term]} --json #{@explorer_data[:path]}".split
      # puts @explorer_data[:search_term].inspect
      # puts cmd.join
      @io.getCmdData(cmd).split("\n")
    end

    def autopilot
      choices, box = summary_box
      max_height = choices.size
      clear_screen
      print box
      prompt = TTY::Prompt.new
      option = prompt.enum_select('Select an option', choices)
      text_detail = @nodes[option].matches(screen_width) # XXX Here we get the text to print in the right box below
      detail = TTY::Box.frame(top: 0, left: 31, width: screen_width - 32, height: max_height + 2) { text_detail }
      print detail

      loop do
        puts
        prompt = TTY::Prompt.new
        option = prompt.enum_select('Select an option', choices)  
        break if option == 'q'
        text_detail = @nodes[option].matches(screen_width) # XXX Here we get the text to print in the right box below
        max_height = [choices.size, text_detail.count("\n") - 1].max
        detail = TTY::Box.frame(top: 0, left: 31, width: screen_width - 32, height: max_height + 2) { text_detail }
        individual_action(option) unless @explorer_data[:quick]
        clear_screen
        print box + detail
      end
    end

    def menu
      puts "AAAAAAAAAA"
      prompt = TTY::Prompt.new
      box = TTY::Box.frame(width: 30, height: 10) do
        "Drawin a box in terminal emulator"
      end
      loop do
        choices = [
          { name: 'Autopilot', value: 1 },
          { name: 'View names of files', value: 2 },
          { name: 'View summary', value: 3 },
          { name: 'Take action', value: 4 },
          { name: 'Quit', value: 'q' }
        ]
        option = prompt.enum_select('Select an option', choices)
        # puts "option: #{option.inspect}"
        case option
        when 1
          autopilot
        when 2
          # puts @nodes.reduce('') { _1 + _2.to_s }
          @nodes.each do |node|
            puts node.name_file
          end
        when 3
          @nodes.each do |node|
            puts node.summary
          end
        when 4
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

