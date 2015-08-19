# Puppet Tomcat(s) Module

## Introduction

With this Puppet module you can manage several Apache Tomcat instances on one node. You are able to deploy multiple instances of different Tomcat versions each with separate Java versions if needed.
This module handles Apache Tomcat on Linux (preferred, of course ;-) ) and also on Windows. I used Tanuki Java Service Wrapper on Linux and recommend to use YAJSW on Windows to install a service for the instance. Java/Tomcat configuration is set in (yajsw)/conf/wrapper.conf and you can customize your settings afterwards.

On Linux it is also possible to update each Tomcat instance. When you change "tomcat_release" then a new tarball will be extracted into your tomcat directory. All of the files in conf/ won't be overwritten.

## Requirements
### Linux
You only need wget and tar installed on your node. Your node also needs Internet access for downloading the tarballs from Apache Tomcat and Java Service Wrapper. You can also change overwrite the download URLs to fetch the archives from your local network.

### Windows
You need Powershell installed on your node to download and extract the zip-archives. Also download via Internet by default and possibility to overwrite download URLs with your local network URLs. 

## Usage of this module

! IMPORTANT !
Please make sure the value of tomcat_number is set to "01", "02", "03" and so on. This module needs this number to generate the nessecary ports for every instance and is also naming the appropriate directory like /srv/tomcat/tomcat[number] or C:\Tomcat\tomcat[number].
You can use the optional/additional variable "tomcat_description => 'livesystem'" to define a user-friendly, human-readable and understandable subdiretory like /srv/tomcat/tomcat01_livesystem or C:\Tomcat\Tomcat01_livesystem and also Windows service display name and description.

#### Linux
Usage in site.pp, two Tomcat instances with possible options, e.g.
```puppet
   tomcats::windows::install { '01':
      tomcat_number => '01',
      tomcat_release => '8.0.24',
      wrapper_release => '3.5.21',
      java_home => '/usr/lib/jvm/jdk-8-oracle-x64',
      download_tomcat_from => 'http://archive.apache.org',
      download_wrapper_from => 'http://wrapper.tanukisoftware.com/download',
   }

   tomcats::windows::install { '02':
      tomcat_number => '02',
      tomcat_release => '7.0.54',
      wrapper_release => '3.5.21',
      java_home => '/usr/lib/jvm/jdk-7-oracle-x64',
      download_tomcat_from => 'http://archive.apache.org',
      download_wrapper_from => 'http://wrapper.tanukisoftware.com/download',
   }
```
Usage in your ENC like Foreman
```puppet
The Foreman will recognize the class instance.pp class and you can override via smart class parameters. Parameters are stored in a hash and you can use YAML to define your options.

   example01:
     tomcat_number: '01'
     tomcat_release: 8.0.24
     java_home: /usr/lib/jvm/jdk-8-oracle-x64
   example02:
     tomcat_number: '02'
     tomcat_release: 7.0.54
     java_home: /usr/lib/jvm/jdk-7-oracle-x64
```

#### Windows
Usage in site.pp

Apache Tomcat without any service or wrapper
```puppet
 tomcats::windows::install { '01':
  tomcat_number           => '01',
  tomcat_release          => '8.0.24',
  parent_inst_dir         => 'C:\Tomcat',
  install_tempdir_windows => 'C:\Windows\Temp',
  download_tomcat_from    => 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24-windows-x64.zip',
  autostart               => false,
}
```

Apache Tomcat with Yet Another Java Service Wrapper (YAJSW)
```puppet
tomcats::windows::install { '01':
  tomcat_number           => '01',
  tomcat_release          => '8.0.24',
  parent_inst_dir         => 'C:\Tomcat',
  install_tempdir_windows => 'C:\Windows\Temp',
  download_tomcat_from    => 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24-windows-x64.zip',
  autostart               => false,
  java_home               => 'C:\Java\jdk8',
  wrapper                 => 'yajsw',
  wrapper_release         => '11.11',
  download_wrapper_from   => 'http://downloads.sourceforge.net/project/yajsw/yajsw/yajsw-stable-11.11/yajsw-stable-11.11.zip',
}
```

Apache Tomcat with Tanuki Java Service Wrapper (JSW)
```puppet
tomcats::windows::install { '01':
  tomcat_number           => '01',
  tomcat_release          => '8.0.24',
  parent_inst_dir         => 'C:\Tomcat',
  install_tempdir_windows => 'C:\Windows\Temp',
  download_tomcat_from    => 'http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.24/bin/apache-tomcat-8.0.24-windows-x64.zip',
  autostart               => false,
  java_home               => 'C:\Java\jdk8',
  wrapper                 => 'tanuki',
  wrapper_release         => '3.5.26',
  download_wrapper_from   => 'http://wrapper.tanukisoftware.com/download/3.5.26/wrapper-windows-x86-64-3.5.26-st.zip',
}
```

Usage in your ENC (Foreman, ...) is like on Linux (see above).

## SUPPORTS
Tested on:
 * Debian, Ubuntu
 * Windows Server 2008, Windows Server 2012, Windows 7
 * Should also work on RPM-based distributions (not tested)

Have Fun with this module and give me feedback! ;-)

## CopyLeft
Copyleft (C) 2015 Marcel Emmert <echomike@gmx.de>
