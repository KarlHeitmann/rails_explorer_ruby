#!/usr/bin/ruby
# frozen_string_literal: true

require 'json'
require_relative 'data_match'
require_relative 'match'
require 'tty-prompt'

# Begin
# properties:
# path
class Begin < DataMatch
  def to_s
    # "type BEGIN: #{@data}\n\t#{@data.keys}"
    "type BEGIN: #{@data.keys}"
    "\tpath: #{@data['path']}"
  end
end

# End
# properties:
# path
# binary_offset
# stats
class End < DataMatch
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
end

# Summary
class Summary < DataMatch
  def to_s
    s = <<-STRING
    \telapsed_total: #{@data['elapsed_total']}
    \tstats: #{@data['stats']}
    STRING
    # "type SUMMARY: #{@data}\n\t#{@data.keys}"
    "type SUMMARY: #{@data.keys}"
    s
  end
end

# Node models a match from rg --json
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

  def to_s
    # "type: #{@raw_data.class}\n#{@raw_data}\n\n"
    # matches_string = @matches.reduce("---\n") { _1 + "#{_2}\n--------\n\t" }
    matches_string = @matches.reduce("\n") { _1 + "#{_2}\n" }
    # "node\n\tbegin_data: #{@begin_data}\n\tmatches (#{@matches.count}): #{@matches}\n\tend_data#{@end_data}\n"
    "node\n\tbegin_data: #{@begin_data}\n\tMATCHES (#{@matches.count}): \n#{matches_string}\n\tend_data#{@end_data}\n"
  end
end

class Nodes
  def initialize(lines)
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
        @summary = Summary.new(line['data'])
      else
        puts line
        1 / 0
      end
    end
    @nodes = grouped_lines.map { Node.new(_1) }
  end

  def to_s
    @nodes.reduce('') { _1 + _2.to_s }
  end
end

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

def run()
  while true
    prompt = TTY::Prompt.new
    choices = [
      {name: "Use example rg def --jsonsmall", value: 1},
      {name: "Run your own command", value: 2,},
      {name: "Quit", value: "q",},
    ]
    option = prompt.enum_select("Select an option", choices)
    puts "option: #{option.inspect}"
    # break
    if option == "1"
      io = IOUtils.new
      cmd = 'rg def --json'.split
      lines = io.getCmdData(cmd).split("\n")
      nodes = Nodes.new(lines)
      puts nodes
    elsif option == "q"
      break
    else
      cmd = gets().chomp
      io = IOUtils.new
      lines = io.getCmdData(cmd).split("\n")
      nodes = Nodes.new(lines)
      puts nodes
    end
  end
end

run()

