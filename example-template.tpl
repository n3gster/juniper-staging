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