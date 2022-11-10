require_relative 'explorer/node'

module Explorer
  # Helper class to deal with IO
  class IOUtils
    def getCmdData(cmd)
      io = IO.popen(cmd)
      data = io.read
      io.close
      # raise 'it failed!' unless $?.exitstatus == 0
      data
    end
  end

  # Main Nodes for explorer class
  class Nodes
    def self.tty_screen_width
      # puts "bla bla bla"
      TTY::Screen.columns
    end

    def screen_width
      @screen_width ||= self.class.tty_screen_width
    end

    def parse_data(lines, aux = [], grouped_lines = [])
      lines.each do |line_string|
        line = JSON.parse line_string
        # t = line['type']
        if %w[begin match].include? line['type']
          aux << line
        elsif line['type'] == 'summary'
          @summary = line['data']
        elsif line['type'] == 'end'
          aux << line
          grouped_lines << aux
          aux = []
        else
          1 / 0
        end
      end
      grouped_lines
    end

    def initialize(explorer_data:)
      # @autopilot = autopilot
      @io = IOUtils.new
      @explorer_data = explorer_data
      @filter = ''
      puts ':::::::'
      puts @explorer_data.inspect
      # 1/0
      lines = rg_launch
      grouped_lines = parse_data(lines)
      @nodes = grouped_lines.map { Node.new(_1, explorer_data: explorer_data) }
      # @columns = TTY::Screen.columns
    end

    def summary_box_and_filenames_choices
      # TODO: Adjust size of the box accordingly
      text_to_display = ''
      choices = []
      nodes = @nodes.filter { _1.name_file.include? @filter }
      nodes.each_with_index do |node, i|
        file_name = node.name_file.gsub(@explorer_data[:prefix], '')
        text_to_display << file_name << "\n"
        # choices << { name: node.name_file, value: i + 1}
        choices << { name: file_name, value: i + 0 }
      end
      choices << { name: 'Quit', value: 'q' }
      # title = @explorer_data[:search_term]
      title = { top_left: @explorer_data[:search_term], bottom_right: @explorer_data[:path] }
      # puts title
      # box = TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: {top_left: title, bottom_right: "v1.0"}) { text_to_display }
      [TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: title) { text_to_display }, choices]
    end

    def summary_box
      # TODO: Adjust size of the box accordingly
      text_to_display = ''
      nodes = @nodes.filter { _1.name_file.include? @filter }
      nodes.each_with_index do |node, i|
        file_name = node.name_file.gsub(@explorer_data[:prefix], '')
        text_to_display << file_name << "\n"
      end
      title = { top_left: @explorer_data[:search_term], bottom_right: @explorer_data[:path] }
      TTY::Box.frame(top: 0, width: 30, height: nodes.size + 2, title: title) { text_to_display }
    end

    def individual_action(option)
      complete_file_name = @nodes[option].name_file
      file_name = complete_file_name.split('/')[-1]
      if (file_name[0] == '_') && (file_name[-3..] == 'erb')
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
      box, choices = summary_box_and_filenames_choices
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

    def input_filter(prompt)
      @filter = ''
      box = nil
      loop do
        box = summary_box
        clear_screen
        print box
        c = prompt.keypress("> #{@filter}:")
        break if c == "\r"

        if c == "\u007F" # This is a backspace
          @filter = @filter[0...-1]
          next
        end
        @filter << c
      end
      box
    end

    def menu
      box = summary_box
      puts "AAAAAAAAAA"
      prompt = TTY::Prompt.new
      loop do
        clear_screen
        print box
        choices = [
          { name: 'Explore', value: 1 },
          { name: 'Filter', value: 2 },
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
          box = input_filter(prompt)
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

