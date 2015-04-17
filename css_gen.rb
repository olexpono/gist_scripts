#! /usr/bin/env ruby
pattern = ARGV[0]
progression = ARGV[1]
count = ARGV[2]

puts "ARGV: "
puts ARGV

var_regexp = /\{[^}]*\}/

fib = Enumerator.new do |y|
  a = b = 1
  loop do
    y.yield a
    a, b = b, a + b
  end
end

# "{1}px {1}px {-0.03}px rgba(0,0,0,0.75)" fib 300
count.to_i.times do |x|
  out = fib.next.to_f
  # puts "=== #{out}"
  outpattern = pattern.dup

  comma = x != (count.to_i - 1) ? ",\n" : ";\n"
  pattern.scan(var_regexp) do |match|
    computed_value = match[1..-1].to_f * out
    outpattern = outpattern.sub(match, computed_value.to_i.to_s)
  end

  STDOUT.write outpattern + comma
end

