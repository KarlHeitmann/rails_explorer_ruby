#!/usr/bin/ruby
# frozen_string_literal: true

require 'json'
require_relative 'command'
require_relative 'explorer'
# require_relative 'node'
require 'tty-prompt'
require 'tty-box'
require 'tty-screen'


# IOUtils is used to retrieve data fro IO sucprocess with only one command HACK_ME
class IOUtils
  def getCmdData(cmd)
    io = IO.popen(cmd)
    data = io.read
    io.close
    # raise 'it failed!' unless $?.exitstatus == 0
    data
  end
end

def clear_screen
  puts "\e[H\e[2J"
end

def run
  # clear_screen
  cmd = Command.new
  cmd.parse
  cmd.run
  puts cmd.params
  # puts cmd.help
  puts cmd.params[:autopilot]
  if cmd.params[:autopilot]
    io = IOUtils.new
    cmd = 'rg run --json'.split
    lines = io.getCmdData(cmd).split("\n")
    nodes = Explorer::Nodes.new(lines)
    nodes.autopilot
  else
    prompt = TTY::Prompt.new
    loop do
      choices = [
        { name: 'Use example rg def --json', value: 1 },
        { name: 'Use example rg run --json', value: 2 },
        { name: 'Run your own command', value: 3 },
        { name: 'Quit', value: 'q' }
      ]
      option = prompt.enum_select('Select an option', choices)
      puts "option: #{option.inspect}"
      # break
      case option
      when 1
        io = IOUtils.new
        cmd = 'rg def --json'.split
      when 2
        io = IOUtils.new
        cmd = 'rg run --json'.split
      when 'q'
        break
      else
        cmd = gets.chomp
      end
      lines = io.getCmdData(cmd).split("\n")
      nodes = Explorer::Nodes.new(lines)
      nodes.menu
      # puts nodes
    end
  end
end

run
