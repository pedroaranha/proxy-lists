#!/usr/bin/env ruby

require 'resolv'

def proxy(timeout = nil)
    unless File.file?('proxies.csv')
        %x(proxy-lists getProxies --output-format="csv")
    end
    puts 'Done generating proxy list. Total of ' + %x(wc -l proxies.csv | awk '{print $1}').strip + ' proxies found from 12 sources.'
    input = File.open('proxies.csv', 'r')
    output = File.open('proxiesreverse.csv', 'w')
    output.puts "ipAddress,port,country,protocols,anonymityLevel,reverse"
    timeout.nil? ? resolver = Resolv::DNS.new : resolver = Resolv::DNS.new(:timeouts => timeout)
    puts 'Getting reverse DNS for proxies. This is VERY slow at default timeout, so come back tomorrow...'
    input.each_with_index do |line, index|
    begin
        unless index == 0
            line_array = line.split(',')
            line_array[5] = resolver.getname(line_array.first)
            output.puts line_array.join(',')
        end
    rescue
        line_array = line.split(',')
        line_array[5] = 'no-name'
        output.puts line_array.join(',')
    end
    end
    input.close
    output.close
    puts 'done'
end

proxy(ARGV[0])