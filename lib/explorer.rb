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
        if %w[begin context match].include? line['type']
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
        choices << { name: file_name, value: i + 0 }
      end
      choices << { name: 'Quit', value: 'q' }
      title = { top_left: @explorer_data[:search_term], bottom_right: @explorer_data[:path] }
      [TTY::Box.frame(top: 0, width: 30, height: choices.size + 2, title: title) { text_to_display }, choices]
    end

    def filenames_filtered
      @nodes
        .filter { _1.name_file.include? @filter }
        .map { "#{_1.name_file.gsub(@explorer_data[:prefix], '')}:#{_1.matches_count}" }
    end

    def summary_box
      # TODO: Adjust size of the box accordingly
      text_to_display = ''
      nodes = @nodes.filter { _1.name_file.include? @filter }
      nodes.each do |node|
        file_name = node.name_file.gsub(@explorer_data[:prefix], '')
        # text_to_display << "#{node.matches_count}:#{file_name}\n"
        text_to_display << "#{file_name}:#{node.matches_count}\n"
      end
      title = { top_left: @explorer_data[:search_term], bottom_right: @explorer_data[:path] }
      # TTY::Box.frame(top: 0, width: 30, height: nodes.size + 2, title: title) { text_to_display }
      TTY::Box.frame(top: 0, height: nodes.size + 2, title: title) { text_to_display }
    end

    def individual_action(option)
      complete_file_name = @nodes[option].name_file
      file_name = complete_file_name.split('/')[-1]
      return unless (file_name[0] == '_') && (file_name[-3..] == 'erb')

      clear_screen
      prompt = TTY::Prompt.new
      choices = [
        { name: file_name, value: 1 },
        { name: 'Quit', value: 'q' },
      ]
      option = prompt.enum_select("====> Select an option for #{complete_file_name}", choices)  
      return if option == 'q'

      explorer_child_data = @explorer_data
      explorer_child_data[:search_term] = "render.*#{file_name.split('.').first[1..]}"
      explorer_child = Nodes.new(explorer_data: explorer_child_data)
      explorer_child.menu
    end

    def rg_launch
      # cmd = "rg #{@explorer_data[:search_term]} --json #{@explorer_data[:path]}".split
      cmd = "rg #{@explorer_data[:search_term]} #{@explorer_data[:path]} -A 2 -B 2 --json".split
      @io.getCmdData(cmd).split("\n")
    end

    def explore
      choices = filenames_filtered.map.with_index { { name: _1, value: _2 } }
      # max_height = choices.size
      prompt = TTY::Prompt.new
      clear_screen
      loop do
        option = prompt.enum_select('Select an option', choices + [{ name: 'Quit', value: 'q' }])
        clear_screen
        break if option == 'q'

        text_detail = @nodes[option].matches
        max_height = [choices.size, text_detail.count("\n")].max
        # title = { top_left: @explorer_data[:search_term], bottom_right: @explorer_data[:path] }
        title = { top_left: " #{@nodes[option].name_file} " }
        # binding.pry
        detail = TTY::Box.frame(top: 0, width: screen_width, height: max_height + 2, title: title) { text_detail }
        print detail

        # max_height = [choices.size, text_detail.count("\n")].max
        individual_action(option) unless @explorer_data[:quick]
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
      prompt = TTY::Prompt.new
      loop do
        clear_screen
        print box
        choices = [
          { name: 'Explore', value: 1 },
          { name: 'Filter', value: 2 },
          { name: 'Quit', value: 'q' }
        ]
        option = prompt.enum_select('Select an option', choices)
        case option
        when 1
          explore
        when 2
          box = input_filter(prompt)
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

