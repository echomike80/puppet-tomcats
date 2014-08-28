# Puppet Tomcat(s) Module

## Introduction

Yeah, there are several Tomcat module at the Puppetforge. With this Puppet module you can manage several Apache Tomcat instances on one node. You are able to deploy multiple instances of different Tomcat versions each with separate Java versions if needed.
This module handles Apache Tomcat on Linux (preferred, of course ;-) ) and also on Windows. I used Tanuki Java Service Wrapper to install a service for the instance. Java/Tomcat configuration is set in conf/wrapper.conf and you can customize your settings in conf/wrapper-custom.conf.

On Linux it is also possible to update each Tomcat instance. When you change "tomcat_release" then a new tarball will be extracted into your tomcat directory. Most of the files in conf/ won't be overwritten, so the show will go on. :-)

## Requirements
### Linux
You only need wget and tar installed on your node. Your node also needs Internet access for downloading the tarballs from Apache Tomcat and Java Service Wrapper.

### Windows (a little bit more complicated)
You need 7-Zip installed on your node to extract the zip-archives. The zip-archives should be stored on a Windows/Samba share like \\puppet\softwaredistribution\apache-tomcat\releases\7.0.54\apache-tomcat-7.0.54-windows-x64.zip and \\puppet\softwaredistribution\java-wrapper\releases\3.5.21\wrapper-windows-x86-64-3.5.21-st.zip.
You can set your custom softwaredistribution share like "\\server\whatever" by overriding variables download_tomcat_from => "\\\\server\\whatever", and download_wrapper_from => "\\\\server\\whatever", in your hash definition (see paragraph "Comprehensive usage").

## Usage of this module

### Simple usage

#### Linux
This will deploy a Tomcat 5.5.36 in /srv/tomcat/tomcat01 using /usr/lib/jvm/j2sdk1.6-oracle as JAVA_HOME, because of my default values.
```puppet
   class { tomcats::instance: }
```

#### Windows
Tomcat 5.5.36 in C:\Program Files\Tomcat01 using C:\Program Files\Java\jdk6 as JAVA_HOME, because of my default values.
```puppet
   class { tomcats::windows::instance: }
```

### Comprehensive usage
Two Tomcat instances with possible options, e.g.

* `! IMPORTANT !`
* `Please make sure the value of tomcat_number is set to "01", "02", "03" and so on. This module needs this number to generate the nessecary ports for every instance and is also naming the appropriate directory like /srv/tomcat/tomcat[number].`

#### Linux
Usage in site.pp
```puppet
   class { tomcats::instance:
     tomcat_instances => {
       'example01' => {
         tomcat_number => '01',
         tomcat_release => '7.0.54',
         java_home => '/usr/lib/jvm/java-7-openjdk-amd64',
       },
       'example02' => {
         tomcat_number => '02',
         tomcat_release => '6.0.26',
         java_home => '/usr/lib/jvm/java-6-openjdk-amd64',
       },
     }
   }
```
Usage in your ENC like Foreman
```puppet
The Foreman will recognize this class and you can override via smart class parameters. Parameters are stored in a hash and you can use YAML to define your options.

   example01:
     tomcat_number: '01'
     tomcat_release: 7.0.54
     java_home: /usr/lib/jvm/java-7-openjdk-amd64
   example02:
     tomcat_number: '02'
     tomcat_release: 6.0.26
     java_home: /usr/lib/jvm/java-6-openjdk-amd64
```

#### Windows
Usage in site.pp
```puppet
   class { tomcats::windows::instance:
     tomcat_instances => {
       'example01' => {
         tomcat_number => '01',
         tomcat_release => '7.0.54',
         java_home => '/usr/lib/jvm/java-7-openjdk-amd64',
         download_tomcat_from => '\\server\whatever',
         download_wrapper_from => '\\server\whatever',
       },
       'example02' => {
         tomcat_number => '02',
         tomcat_release => '6.0.26',
         java_home => '/usr/lib/jvm/java-6-openjdk-amd64',
         download_tomcat_from => '\\server\whatever',
         download_wrapper_from => '\\server\whatever',
       },
     }
   }
```
Usage in your ENC (Foreman, ...) is like on Linux (see above).

## SUPPORTS
Tested on:
 * Debian, Ubuntu (RPM-based distributions should also work fine)
 * Windows Server 2008

## TODO
 * Linux: exception, if a package download fails or package is corrupt
 * Linux: tomcat-wrapper.sh not from template
 * Windows: better Tomcat update routine

Have Fun with this module and give me feedback! ;-)

## CopyLeft
Copyleft (C) 2013 Marcel Emmert <echomike@gmx.de>
