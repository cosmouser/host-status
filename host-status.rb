require 'rufus-scheduler'
require 'net/ping'

# This is a monitoring tool for checking server status. It pings each host at
# 15 minute intervals. If a host is down for two consecutive intervals then
# it sends an email to a system administrator or creates a ticket. 
#
# After a notification has been sent, no additional notices will be sent until
# the host has been found to repsond at least once.

# list of servers
# replace with the hosts that you want the service to check in here
hosts = %w(	
  host1.domain
  host2.domain
  host3.domain
  et.cetera.domain
  10.30.50.100
  192.168.1.1
)

# ping a single host
def ping(host)
	p_host = Net::Ping::External.new(host)
	return p_host.ping?
end

# outage handler: what will we do when there is an outage?
def handle_outage(host)
	# do something
end

# create a monitoring list with a counter
# [["host1.domain", 0],
#  ["host2.domain", 0]] etc
def initialize_list(hosts)
	hosts.zip(Array.new(hosts.size, 0))
end

# 'list' is an array of hosts made from the initialize_list method
def ping_list(list)
	list.each do |entry|
		# ping the host, if the host is online, reset counter
		# to 0. if the host is not online, add 1 to the counter
		if ping(entry[0])
			entry[1] = 0
		else
			entry[1] += 1
		end
		# if the host hasn't responded to two consecutive pings
		# call the outage handler
		if entry[1] == 2
			handle_outage(entry[0])
		end
	end
	# return the updated list for the next scheduled run
	return list
end

def start_scheduler(hosts)
	list = initialize_list(hosts)
	scheduler = Rufus::Scheduler.new
	scheduler.every '15m' do
		list = ping_list(list)
	end
	scheduler.join
end

start_scheduler(hosts)
