#! /usr/bin/ruby

require 'parseconfig'

config = ParseConfig.new(ARGV[0])
template_file = config['template_file']
unless File.file?(template_file)
	puts "ERROR: Check the template_file configuration variable is correct (points to a valid template's filename) in #{ARGV[0]}"
	abort
end

# Make an array to hold errors in.  If errors are found in the config, the template will not build and the errors will be printed.
list_errors = []

job_list = config['make'].split
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
		@list_tpl_users.each do |new_user|
		puts "User - #{new_user['user_name']} is allowed #{new_user['user_class']} privs with password #{new_user['password']}."
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
end

