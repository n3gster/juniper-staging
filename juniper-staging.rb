#! /usr/bin/ruby

require 'parseconfig'
require 'erb'
require 'IPAddr'

config = ParseConfig.new(ARGV[0])
template_file = config['template_file']
unless File.file?(template_file)
	puts "ERROR: Check the template_file configuration variable is correct (points to a valid template's filename) in #{ARGV[0]}"
	abort
end

load_template_file = File.open(template_file, "rb")
router_template = load_template_file.read
load_template_file.close

# Make an array to hold errors in.  If errors are found in the config, the template will not build and the errors will be printed.
list_errors = []

# Get the mgmt prefix as an integer
begin
	# Count how many IP addresses I need
	num_ip_needed = config['routers'].count

	# Calculate management address details, see if subnet is large enough
	mgmt_first = IPAddr.new config['mgmt_subnet']
	mgmt_num_hosts = mgmt_first.to_range.count - 2
	if mgmt_num_hosts < num_ip_needed
		list_errors.push("ERROR:Subnet for Management network is not large enough - #{num_ip_needed} addresses needed and #{mgmt_num_hosts} in subnet.")
	end
	next_ip_assign_mgmt = IPAddr.new mgmt_first.to_i + 1,Socket::AF_INET

	# Calculate loopback address details, see if subnet is large enough
	loopback_first = IPAddr.new config['loopback_subnet']
	loopback_num_hosts = loopback_first.to_range.count - 2
	if loopback_num_hosts < num_ip_needed
		list_errors.push("Subnet for Loopback network is not large enough - #{num_ip_needed} addresses needed and #{loopback_num_hosts} in subnet")
	end
	next_ip_assign_loopback = IPAddr.new loopback_first.to_i + 1,Socket::AF_INET
rescue
	puts "ERROR: Check the mgmt_subnet and loopback_subnet options are right in #{ARGV[0]}, because I failed to parse them as a valid IPv4 subnet"
	abort
end

# Mandatory entires - you always need to build the hostname and management info, and loopbacks.  At least when using this script. :-)
@list_tpl_routers = []
config['routers'].each do |router_hostname, router_mgmt|
	new_router = {}
	new_router['hostname'] = router_hostname
	new_router['mgmt_port'] = router_mgmt
	new_router['mgmt_ip']   = next_ip_assign_mgmt.to_s
	new_router['loopback_ip'] = next_ip_assign_loopback.to_s
	new_router['syslog_host'] = config['syslog_host']
	new_router['ntp_host'] = config['ntp_host']
	next_ip_assign_loopback=next_ip_assign_loopback.succ
	next_ip_assign_mgmt=next_ip_assign_mgmt.succ
	puts "router #{router_hostname} will get #{new_router['mgmt_ip']}"
	@list_tpl_routers.push(new_router)
end

# Optional entries - you may want to make username blocks, igp blocks and ibgp blocks - these are setup here.
job_list = config['make'].split(",")
puts "Jobs: #{job_list}"
job_list.each do |job|
	case job
		when "users"
			# Make a username block with passwords to pass into template
			@list_tpl_users = []
			config['users'].each do |user_name, user_class|
				new_user = {}
				new_user['user_name']  = user_name
				if not ["operator","read-only","superuser","super-user","unauthorised","only-view-config"].include?(user_class)
					list_errors.push("ERROR: user #{user_name} has invalid class - #{user_class}")
				end
				new_user['user_class'] = user_class
				new_user['password']   = ('a'..'z').to_a.shuffle[0,8].join
				@list_tpl_users.push(new_user)
			end

		when "isis"
			@flag_tpl_isis = 'yes'
			# spoof an iso address by wanging a count in
			counter = 1
			@list_tpl_routers.each do |router|
				# FIXME, pad counter to four digits
				router['iso_addr'] = "49.0001.0101.0000.#{counter}.00"
				counter=counter+1
			end
	end
end

# Abort the script and print errors, if there are any
if list_errors.count > 0
	list_errors.each do |error|
		puts error
		abort
	end
else
	puts "Make template"
	@list_tpl_routers.each do |router|
		@router = router
		puts "doing #{@router['hostname']} (#{router['iso_addr']})"
		render = ERB.new router_template
		puts render.result
	end
end

puts @list_tpl_routers