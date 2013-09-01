system {
	hostname = <%= @router['hostname'] %>;
	<% if defined?(@list_tpl_users) %> <% for user in @list_tpl_users %>
	user <%= user['user_name'] %> {
		class <%= user['user_class'] %>;
		authentication {
			password "<%= user['password'] %>";
		}
	}
	<% end %><% end %>

	services {
		ssh;
		netconf {
			ssh;
		}
	}

	syslog {
		user * {
			any emergency;
		}
		host <%= @router['syslog_host'] %> {
			any any;
			authorization info;
			interactive-commands info;
		}
	}
	file messages {
		any notice;
		authorization info;
	}
}

interfaces {
	lo0 {
        unit 0 {
            family inet {
                address <%= @router['loopback_ip'] %>/32;
            }
            <% if @flag_tpl_isis=='yes' %>
            family iso {
                address <%= @router['iso_addr'] %>;
            }
            <% end %>
        }
    }
}