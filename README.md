juniper-staging
===============

Stage a set of Juniper routers, with consistent usernames, loopbacks, igp enabled and ibgp full mesh using a template


Dependencies
============

Built on ruby-parseconfig, written by Derks.  https://github.com/derks/ruby-parseconfig

sudo gem install parseconfig


Running the script
==================

Edit the example config file to your needs, and then run:

ruby juniper-staging.rb [config-filename]
