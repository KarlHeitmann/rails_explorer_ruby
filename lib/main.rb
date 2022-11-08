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
def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end


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
    autopilot = cmd.params[:autopilot]
    quick = cmd.params[:quick]
    search_term = 'run'
    path = cmd.params[:path]
    explorer_data = { autopilot: autopilot, search_term: search_term, quick: quick, path: path }
    nodes = Explorer::Nodes.new(explorer_data: explorer_data)
    nodes.autopilot
  else
    explorer_data = { autopilot: autopilot, search_term: cmd.params[:search_term], quick: quick, path: cmd.params[:path] }
    nodes = Explorer::Nodes.new(explorer_data: explorer_data)
    nodes.menu # TODO: Refactor to run
  end
end

run
