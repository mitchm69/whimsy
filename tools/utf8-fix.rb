#!/usr/bin/env ruby

# @(#) fix non-UTF8 source files

$LOAD_PATH.unshift '/srv/whimsy/lib'
require 'whimsy/utf8-utils'

if __FILE__ == $0
  src = ARGV.shift or raise Exception.new "need input file"
  dst = ARGV.shift || src + '.tmp'
  puts "Input: #{src} output: #{dst}"
  UTF8Utils::repair(src, dst)
end
