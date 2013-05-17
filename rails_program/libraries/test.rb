
# a module to mix into Chef::Recipe to allow for the creation of a Restart Collector Script
module Test
		
  	def collector_script
  	Dir.chdir ("/home/ubuntu/")
  	file.open("restart_collector.sh","w") do |f|
      f.write("""#!/bin/bash
ps `cat ~/resque.pid`
if [ $? -ne 0 ]; then
 cd ~/collector/current
 VERBOSE=1 PIDFILE=~/resque.pid BACKGROUND=yes QUEUE=store_results,extract,store_document,scrape rake resque:work >/home/ubuntu/collector.log 2>&1
fi
""")
		  end  
  	end

end