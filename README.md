Puppet Tomcat Module
====================

Introduction
------------

Puppet module to manage several tomcat instances

## Usage ##

Tomcat with all options:

    tomcat::install { 'NUMBER':
	tomcat_release => 'VERSION',		Default: 7.0.47
	java_home => 'PATHTOJDK',		Default: /usr/lib/jvm/j2sdk1.6-oracle
	tomcat_user= 'TOMCATUSER',		Default: tomcat
	tomcat_locales => 'LOCALES',		Default: de_DE@euro
    }


TODO
----

 * ldap::server::master and ldap::server::slave do not copy
   the schemas specified by *index_inc*. It just adds an include to slapd
 * Need support for extending ACLs

CopyLeft
---------

Copyleft (C) 2013 Marcel Emmert <marcel.emmertgecg-leipzig.de> (a.k.a. echomike)

