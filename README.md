Puppet Tomcat Module
====================

Introduction
------------

Puppet module to manage several tomcat instances on one node

## Usage ##

**Simple usage:**

class { tomcats::multiple::tomcat01: }

**Tomcat with all possible options (example):**

class { tomcats::multiple::tomcat01:  
      tomcat_release => '7.0.52',  
      java_home => '/usr/lib/jvm/j2sdk1.6-oracle',  
      download_tomcat_from => 'http://archive.apache.org',  
      download_wrapper_from => 'http://wrapper.tanukisoftware.com/download',  
      tomcat_user => 'tomcat',  
      tomcat_locales => 'de_DE@euro',  
}

These default value are set in params.pp and you can override! ;-)

I have included 2 tomcat instances (tomcats::multiple::tomcat01 and tomcats::multiple::tomcat02). You can easily add more pp-files into multiple directory (copy tomcat01) and modify the first 2 lines.

SUPPORTS
--------
Tested on:
- Debian
- Ubuntu

TODO
----

 * hiera support
 * exception, if a package download fails or package is corrupt
 * tomcat-wrapper.sh not from template

CopyLeft
---------

Copyleft (C) 2013 Marcel Emmert <echomike@mailbox.org> (a.k.a. echomike)

