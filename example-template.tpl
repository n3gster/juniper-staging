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
}

interfaces {
	lo0 {
        unit 0 {
            family inet {
                address <%= @router['loopback_ip'] %>;
            }
            <% if @flag_tpl_isis=='yes' %>
            family iso {
                address <%= @router['iso_addr'] %>;
            }
            <% end %>
        }
    }
}