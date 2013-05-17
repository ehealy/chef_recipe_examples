#! /home/ubuntu/.rbenv/shims/ruby

## Script to detect orphan xvfb processes left behind by firefox processes

handles=`lsof -U | grep Xvfb`.split("\n").map { |line| line.split }
good_procs = handles.select { |proc| proc[3][0].to_i > 4 }
all_pids = handles.map { |proc| proc[1] }.uniq
keep_pids = good_procs.map { |proc| proc[1] }.uniq
kill_pids = all_pids - keep_pids

puts "All: #{all_pids}"
puts "Keep: #{keep_pids}"
puts "Kill: #{kill_pids}"

foxes=`ps -C firefox --noheaders | wc`.split[0].to_i


puts "#{foxes} firefoxs to #{keep_pids.length} Xvfbs.  #{foxes == keep_pids.length}"

kill_pids.each { |pid| `kill #{pid}` } #unless foxes != keep_pids.length

