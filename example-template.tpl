system {
	<% for user in @list_tpl_users %>
	user <%= user['user_name'] %> {
		class <%= user['user_class'] %>;
		authentication {
			password <% user['password'] %>
		}
	}
	<% end %>
}