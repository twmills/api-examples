#!/usr/bin/env ruby
$LOAD_PATH.unshift File.dirname(__FILE__)
require "pdclient"
require "active_support/time"

def shutup_all_services(client, duration_in_minutes)
  now = Time.now
  client.create_maintenance_window client.services, :description => "Shutting up for #{duration_in_minutes} minutes",
                                                    :start_time => now,
                                                    :end_time => now + duration_in_minutes.minutes
end

def doit
  return puts "Usage: %s duration_in_minutes subdomain username password" % __FILE__ if ARGV.length != 4
  duration_in_minutes, subdomain, username, password = ARGV
  puts "Shutting up all services for #{subdomain}"
  shutup_all_services(client = PDClient.new(subdomain, username, password), duration_in_minutes.to_i)
  puts "All services are now quiet..."
end

if $PROGRAM_NAME == __FILE__
  doit
end
