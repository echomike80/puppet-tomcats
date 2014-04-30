# tomcats::install resource will be used by multile/tomcatxx.pp classes

define tomcats::install2 ( 
  $tomcat_number,
  $tomcat_release,
  $wrapper_release,
  $java_home,
  $download_tomcat_from,
  $download_wrapper_from,
  $tomcat_locales,
) {

  ################################################
  #                                              #
  #   Definition of variables for installation   #
  #                                              #
  ################################################

  # Extract major version from tomcat_release
  $majorversion = regsubst($tomcat_release,'^(\d+)\.(\d+)\.(\d+)$','\1')

  case $majorversion {
    5: { $lib_path = "common/lib" }
    default: { $lib_path = "lib"}
  }

  # Extract minor version from tomcat_release
  $minorversion = regsubst($tomcat_release,'^(\d+)\.(\d+)\.(\d+)$','\2')

  # Define package version
  $pkg_tomcat = "apache-tomcat-${majorversion}.${minorversion}"

  # Define tomcat installation directory
  $inst_dir = "/srv/tomcat/tomcat${tomcat_number}"

  # Define Download-URL
  $download_url = "${download_tomcat_from}/dist/tomcat/tomcat-${majorversion}/v${tomcat_release}/bin/apache-tomcat-${tomcat_release}.tar.gz"

  # Define tomcat ports
  case $tomcat_number {
    01, 1: { $http_port = '8080'
      $shutdown_port = '8005'
      $ajp_port = '8009'
      $jmx_port = '9017'
      }
    02, 2: { $http_port = '8090'
      $shutdown_port = '8006'
      $ajp_port = '8010'
      $jmx_port = '9018'
      }
    03, 3: { $http_port = '8091'
      $shutdown_port = '8007'
      $ajp_port = '8011'
      $jmx_port = '9019'
      }
    04, 4: { $http_port = '8092'
      $shutdown_port = '8008'
      $ajp_port = '8012'
      $jmx_port = '9020'
      }
    05, 5: { $http_port = '8093'
      $shutdown_port = '8013'
      $ajp_port = '8014'
      $jmx_port = '9021'
      }
    06, 6: { $http_port = '8094'
      $shutdown_port = '8015'
      $ajp_port = '8016'
      $jmx_port = '9022'
      }
    07, 7: { $http_port = '8095'
      $shutdown_port = '8017'
      $ajp_port = '8018'
      $jmx_port = '9023'
      }
    08, 8: { $http_port = '8096'
      $shutdown_port = '8019'
      $ajp_port = '8020'
      $jmx_port = '9024'
      }
    09, 9: { $http_port = '8097'
      $shutdown_port = '8021'
      $ajp_port = '8022'
      $jmx_port = '9025'
      }
    # Dynamic port number generation from tomcat 10 and higher
    default: {  $http_port = "9${tomcat_number}0"
        $shutdown_port = "9${tomcat_number}1"
        $ajp_port = "9${tomcat_number}2"
        $jmx_port = "9${tomcat_number}3"
       }
        }

  # Define wrapper installation package for OS and arch and define Download-URL
  # i.e.: http://wrapper.tanukisoftware.com/download/3.5.21/wrapper-linux-x86-32-3.5.21.tar.gz

  case $operatingsystem {
    Debian, Linux: {
      case $architecture {
        i386: {
          $pkg_wrapper = "wrapper-linux-x86-32-${wrapper_release}"
          $download_url_wrapper = "${download_wrapper_from}/${wrapper_release}/wrapper-linux-x86-32-${wrapper_release}.tar.gz"
        }
        amd64: {
          $pkg_wrapper = "wrapper-linux-x86-64-${wrapper_release}"
          $download_url_wrapper = "${download_wrapper_from}/${wrapper_release}/wrapper-linux-x86-64-${wrapper_release}.tar.gz"
        }
      }
    }
  }


  ###############################
  #                             #
  #     Installation Tomcat     #
  #                             #
  ###############################

  # create /srv/tomcat/tomcat01, e.g.
  file { "${inst_dir}":
    ensure  => directory,
    owner => tomcat,
  }

  # create /srv/tomcat/tomcat01, e.g.
  file { "${inst_dir}/${pkg_tomcat}":
    ensure => directory,
    owner => tomcat,
    require => File ["$inst_dir"],
  }

  # get tar-file and put it in source-dir (which was created in init class)
  exec { "download_tomcat_${tomcat_number}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/srv/tomcat/source",
    user => tomcat,
    command => "wget -O apache-tomcat-${tomcat_release}.tar.gz ${download_url}",
    creates => "/srv/tomcat/source/apache-tomcat-${tomcat_release}.tar.gz",
    require => File [ "${inst_dir}/${pkg_tomcat}" ],
  }

  exec { "extract_tomcat_${tomcat_number}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/srv/tomcat/source",
    user => tomcat,
    command => "tar --directory /srv/tomcat/source -xzf /srv/tomcat/source/apache-tomcat-${tomcat_release}.tar.gz",
    creates => "/srv/tomcat/source/apache-tomcat-${tomcat_release}/RELEASE-NOTES",
    require => Exec[ "download_tomcat_${tomcat_number}" ],
  }

  exec { "clean_tomcat_${tomcat_number}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/srv/tomcat/source",
    command => "rm -rf apache-tomcat-${tomcat_release}/conf/context.xml apache-tomcat-${tomcat_release}/conf/server.xml apache-tomcat-${tomcat_release}/conf/tomcat-users.xml apache-tomcat-${tomcat_release}/conf/web.xml apache-tomcat-${tomcat_release}/webapps/ROOT apache-tomcat-${tomcat_release}/webapps/docs apache-tomcat-${tomcat_release}/webapps/examples apache-tomcat-${tomcat_release}/webapps/balancer apache-tomcat-${tomcat_release}/webapps/jsp-examples apache-tomcat-${tomcat_release}/webapps/servlets-examples apache-tomcat-${tomcat_release}/webapps/tomcat-docs apache-tomcat-${tomcat_release}/webapps/webdav",
    onlyif => "test -f /srv/tomcat/source/apache-tomcat-${tomcat_release}/conf/context.xml",
    require => Exec [ "extract_tomcat_${tomcat_number}" ],
  }

  exec { "copy_tomcat_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    user => tomcat,
    command => "cp -rf /srv/tomcat/source/apache-tomcat-${tomcat_release}/* ${inst_dir}/${pkg_tomcat}",
    unless => "grep ${tomcat_release} ${inst_dir}/${pkg_tomcat}/RELEASE-NOTES",
    require => Exec [ "clean_tomcat_${tomcat_number}" ],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/tomcat-users.xml":
    content => template("tomcats/tomcat-users.xml.erb"),
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/context.xml":
    content => template("tomcats/context${majorversion}.xml.erb"),
    replace => false,
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/server.xml":
    content => template("tomcats/server${majorversion}.xml.erb"),
    replace => false,
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/web.xml":
    content => template("tomcats/web${majorversion}.xml.erb"),
    replace => false,
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/${lib_path}/ext":
    ensure => directory,
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }

#  # To-Do: Puppet run has to know ENVvar $ORACLE_HOME
#  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/ext/ojdbc6.jar":
#    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
#    command => "cp \$ORACLE_HOME/jdbc/lib/ojdbc6.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/ext/ojdbc6.jar",
#    user => tomcat,
#    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/ext/ojdbc6.jar",
#    require => Exec [ "copy_tomcat_${inst_dir}" ],
#  }

  file { "${inst_dir}/ports.txt":
    ensure => present,
    content => "# File managed by puppet

HTTP-Port: ${http_port}
AJP-Port: ${ajp_port}
Shutdown-Port: ${shutdown_port}",
    owner => tomcat,
    require => Exec ["copy_tomcat_${inst_dir}"],
  }


  ################################
  #                              #
  #     Installation Wrapper     #
  #                              #
  ################################

  # download and extract wrapper archive
  exec { "download_wrapper_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/srv/tomcat/source",
    user => tomcat,
    command => "wget -O ${pkg_wrapper}.tar.gz ${download_url_wrapper}",
    creates => "/srv/tomcat/source/${pkg_wrapper}.tar.gz",
    require => Exec [ "copy_tomcat_${inst_dir}" ],
  }

   exec { "extract_wrapper_${tomcat_number}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/srv/tomcat/source",
    user => tomcat,
    command => "tar  --directory /srv/tomcat/source -xzf /srv/tomcat/source/${pkg_wrapper}.tar.gz",
    creates => "/srv/tomcat/source/${pkg_wrapper}/bin",
    require => Exec [ "download_wrapper_${inst_dir}" ],
  }

  # copy wrapper files into tomcat installation directory
  exec { "${inst_dir}/${pkg_tomcat}/bin/wrapper":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    user => tomcat,
    command => "cp /srv/tomcat/source/${pkg_wrapper}/bin/wrapper ${inst_dir}/${pkg_tomcat}/bin/wrapper",
    creates => "${inst_dir}/${pkg_tomcat}/bin/wrapper",
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp /srv/tomcat/source/${pkg_wrapper}/lib/libwrapper.so ${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
    user => tomcat,
    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp /srv/tomcat/source/${pkg_wrapper}/lib/wrapper.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
    user => tomcat,
    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  file { "${inst_dir}/${pkg_tomcat}/bin/tomcat-wrapper.sh":
    # deploy own tomcat-wrapper start script
    content => template('tomcats/tomcat-wrapper.sh.erb'),
    owner => tomcat,
    group => 'users',
    mode => 0755,
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  # deploy wrapper configuration

  file { "${inst_dir}/${pkg_tomcat}/conf/wrapper.conf":
    content => template('tomcats/wrapper.conf.erb'),
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/wrapper-custom.conf":
    content => template('tomcats/wrapper-custom.conf.erb'),
    replace => false,
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  # Overwrite default tomcat startup and shutdown script with custom scripts

  file { "${inst_dir}/${pkg_tomcat}/bin/startup.sh":
    content => template('tomcats/startup.sh.erb'),
    owner => tomcat,
    group => 'users',
    mode => 0755,
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh":
    content => template('tomcats/shutdown.sh.erb'),
    owner => tomcat,
    mode => 0755,
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  # deploy Linux init-Script

  file { "/etc/init.d/tomcat${tomcat_number}":
    content => template('tomcats/initscript.erb'),
    owner => tomcat,
    group => 'users',
    mode => 0755,
    require => File [ "${inst_dir}/${pkg_tomcat}/bin/startup.sh" ],
  }

  # symlinks im tomcat homedir (if available)

  file { "/home/tomcat/tomcat${tomcat_number}":
    ensure => link,
    target => "$inst_dir",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/logs":
    ensure => link,
    target => "$inst_dir/$pkg_tomcat/logs",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/webapps":
    ensure => link,
    target => "$inst_dir/$pkg_tomcat/webapps",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/startup.sh":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/bin/startup.sh",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/shutdown.sh":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }
  file { "${inst_dir}/wrapper.log":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/logs/wrapper.log",
    owner => tomcat,
    group => 'users',
    require => Exec [ "extract_wrapper_${tomcat_number}" ],
  }

  ################################
  #                              #
  #     Restart after update     #
  #                              #
  ################################


  # Restart service after tomcat update or wrapper update or configuration update, but only if tomcat[x].pid exists in bin directory
  exec { "restart_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh && ${inst_dir}/${pkg_tomcat}/bin/startup.sh",
    user => tomcat,
    onlyif => "test -f ${inst_dir}/${pkg_tomcat}/bin/tomcat${majorversion}.pid",
    subscribe => [ Exec [ "extract_tomcat_${tomcat_number}" ], Exec [ "extract_wrapper_${tomcat_number}" ], File [ "${inst_dir}/${pkg_tomcat}/conf/wrapper.conf" ], File [ "${inst_dir}/${pkg_tomcat}/bin/startup.sh" ], File [ "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh" ] ],
    refreshonly => true,
  }

#	service { "tomcat${tomcat_number}":
#		ensure => running,
#	}


}
