#!/usr/bin/ruby
# frozen_string_literal: true

require 'json'
require 'pry'
require_relative 'command'
require_relative 'explorer'
# require_relative 'node'
require 'tty-prompt'
require 'tty-box'
require 'tty-screen'

require 'yaml'
# IOUtils is used to retrieve data fro IO sucprocess with only one command HACK_ME
def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text)
  colorize(text, 31)
end

def green(text)
  colorize(text, 32)
end

def clear_screen
  print "\e[H\e[2J"
end

def run
  # clear_screen
  cmd = Command.new
  cmd.parse
  cmd.run
  configuration = YAML.load_file('.code_explorer.yaml')
  configuration['plugins'] = [] if configuration['plugins'].nil?
  explorer_data = cmd.params.to_h.slice(:spanlines, :prefix, :search_term, :autopilot, :quick, :path)
  previous_data = [{search_term: explorer_data[:search_term], path: explorer_data[:path]}]
  nodes = Explorer::Nodes.new(explorer_data: explorer_data, previous_data: previous_data, configuration: configuration)
  if cmd.params[:autopilot]
    nodes.autopilot
  else
    nodes.menu # TODO: Refactor to run
  end
end

run
