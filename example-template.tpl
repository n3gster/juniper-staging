system {
	hostname = <%= @router['hostname'] %>;
	<% for user in @list_tpl_users %>l
	user <%= user['user_name'] %> {
		class <%= user['user_class'] %>;
		authentication {
			password "<%= user['password'] %>";
		}
	}
	<% end %>
}