Rails App Cookbook
======================
This cookbook installs a rails application and the required shell scripts and application specific configuration for maintenance/upkeep on an Ubuntu server. 

Requirements
============
Prior to using this cookbook the git, build-essential, rbenv::user-install, ruby_build, and me_rails should be either installed or added to the chef run list previously. 

Additionally the exim4, monit, and icinga cookbooks should also be optionally installed to make full use of all monitoring tools for the application. 

This cookbook has been created an tested exclusively for Ubuntu v 12.04

Description



Attributes
==========

Usage
=====
#### me_collector::default
