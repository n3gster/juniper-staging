system {
	host-name <%= @router['hostname'] %>;
        <% if defined?(@list_tpl_users) %>
        login {
                <% for user in @list_tpl_users %>
                user <%= user['user_name'] %> {
                        class <%= user['user_class'] %>;
                                authentication {
                                        plain-text-password "<%= user['password'] %>";
                                }
                        }
                <% end %>
        }
        <% end %>	

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
	
		file messages {
			any notice;
			authorization info;
		}
	}
	ntp {
		server <%= @router['ntp_host'] %>;
	}
}

routing-options {
	autonomous-system <%= @router['my_asn'] %>;
}

interfaces {
    <%= @router['mgmt_port'] %> {
        unit 0 {
                family inet {
                        address <%= @router['mgmt_ip'] %>/<%= @router['subnet_size'] %>;
                }
        }
    }

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

protocols {
	<% if @flag_tpl_mpls == 'yes' %>
	rsvp {
        apply-groups RSVP-PARAMETERS;
    }
    mpls {
        apply-groups MPLS-PARAMETERS;
        <% for destrouter in @list_tpl_routers %><% next if destrouter['hostname'] == @router['hostname'] %>
        label-switched-path TO-<%= destrouter['hostname'] %> {
        	to <%= destrouter['loopback_ip'] %>;
        	no-cspf;
        }
        <% end %> 
    }
	<% end %>
	<% if @flag_tpl_ibgp == 'yes' %>
	bgp {
        traceoptions {
            file bgp.log size 10m files 10;
            flag open detail;
        }
        group IBGP {
            type internal;
            local-address <%= @router['loopback_ip'] %>;
            family inet {
                any;
            }
            family inet-vpn {
                any;
            }
            family l2vpn {
                signaling;
            }
            <% for destrouter in @list_tpl_routers %><% next if destrouter['hostname'] == @router['hostname'] %>
            neighbor <%= destrouter['loopback_ip'] %>;<% end %>
        }
    }
	<% end %>
}
