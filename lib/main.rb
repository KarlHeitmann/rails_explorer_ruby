#!/usr/bin/ruby
# frozen_string_literal: true

require 'json'
require_relative 'data_match'
require_relative 'match'

class Begin < DataMatch
  def to_s
    "#{@data}\n\t#{@data.keys}"
    "\tpath: #{@data['path']}"
  end
end

class End < DataMatch
  def to_s
    s = <<-STRING
    \tpath: #{@data['path']}
    \tbinary_offset: #{@data['binary_offset']}
    \tstats: #{@data['stats']}
    STRING
    s
  end
end

class Summary < DataMatch
  def to_s
    s = <<-STRING
    \telapsed_total: #{@data['elapsed_total']}
    \tstats: #{@data['stats']}
    STRING
    "#{@data}\n\t#{@data.keys}"
    s
  end
end


# Node models a match from rg --json
class Node
  def initialize(match)
    d = JSON.parse(match)
    t = d['type']
    klass = dataKlass(t, d['data'])
    @raw_data = klass.new(d['data'])
  end

  def dataKlass(t, d)
    if t == 'begin'
      Begin
    elsif t == 'match'
      Match
    elsif t == 'end'
      End
    elsif t == 'summary'
      Summary
    else
      puts t
      1/0
    end
  end

  def self.parse(match)
    new(match)
  end

  def to_s
    "type: #{@raw_data.class}\n#{@raw_data}\n\n"
  end
end

def run(lines)
  matches = lines.map { Node.parse(_1) }

  matches.each do |match|
    puts match
  end
end

run(ARGF.readlines)
