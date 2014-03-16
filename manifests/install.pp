# tomcats::install resource will be used by multile/tomcatxx.pp classes

define tomcats::install ( 
  $tomcat_number,
  $tomcat_release,
  $java_home,
  $download_from,
  $tomcat_user,
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
	$download_url = "http://${download_from}/dist/tomcat/tomcat-${majorversion}/v${tomcat_release}/bin/apache-tomcat-${tomcat_release}.tar.gz"

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

	# Wrapper Installationspaket für Betriebssystem und Architektur aussuchen und Download-URL definieren
	case $operatingsystem {
		Debian, Linux: {
			case $architecture {
				i386: {
					$pkg_wrapper = "wrapper-linux-x86-32-3.5.21"
					$download_url_wrapper = "http://lsus.ecg-leipzig.de/dist/java-wrapper/wrapper-linux-x86-32-3.5.21.tar.gz"
				}
				amd64: {
					$pkg_wrapper = "wrapper-linux-x86-64-3.5.21"
					$download_url_wrapper = "http://lsus.ecg-leipzig.de/dist/java-wrapper/wrapper-linux-x86-64-3.5.21.tar.gz"
				}
			}
		}
	}


  ###############################
  #                             #
  #     Installation Tomcat     #
  #                             #
  ###############################

  file { "${inst_dir}":
    ensure  => directory,
    owner => $tomcat_user,
    group => users,
  }

  file { "${inst_dir}/${pkg_tomcat}":
    ensure => directory,
    owner => $tomcat_user,
    group => users,
    require => File ["$inst_dir"],
  }

  exec { "download_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/usr/src",
    command => "wget -O apache-tomcat-${tomcat_release}.tar.gz ${download_url}",
    creates => "/usr/src/apache-tomcat-${tomcat_release}.tar.gz",
  }

  exec { "extract_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "tar --directory ${inst_dir}/${pkg_tomcat} --strip-components=1 -xzf /usr/src/apache-tomcat-${tomcat_release}.tar.gz",
    user => $tomcat_user,
    unless => "grep ${tomcat_release} ${inst_dir}/${pkg_tomcat}/RELEASE-NOTES",
    require => [ Exec[ "download_${inst_dir}" ], File[ "${inst_dir}/${pkg_tomcat}" ] ],
  }

  file { [ "${inst_dir}/${pkg_tomcat}/webapps/docs", "${inst_dir}/${pkg_tomcat}/webapps/examples", "${inst_dir}/${pkg_tomcat}/webapps/balancer", "${inst_dir}/${pkg_tomcat}/webapps/jsp-examples", "${inst_dir}/${pkg_tomcat}/webapps/servlets-examples", "${inst_dir}/${pkg_tomcat}/webapps/tomcat-docs", "${inst_dir}/${pkg_tomcat}/webapps/webdav" ]:
    ensure => absent,
    force => true,
    require => Exec ["extract_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/tomcat-users.xml":
    content => template("tomcats/tomcat-users.xml.erb"),
    owner => $tomcat_user,
    group => users,
    require => Exec ["extract_${inst_dir}"],
  }

  file { "${inst_dir}/${pkg_tomcat}/conf/server.xml":
    content => template("tomcats/server${majorversion}.xml.erb"),
    owner => $tomcat_user,
    group => users,
    require => Exec ["extract_${inst_dir}"],
  }

  # To-Do: Wenn sich der Oracle Client ändert wird die neue Lib nicht mehr kopiert
  # Umgebungsvariablen unter Linux müssen geschützt werden mit "\"
  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp \$ORACLE_HOME/jdbc/lib/ojdbc6.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar",
    user => $tomcat_user,
    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar",
    require => Exec [ "extract_${inst_dir}" ],
  }       

  file { "${inst_dir}/ports.txt":
    ensure => present,
    content => "# File managed by puppet

HTTP-Port: ${http_port}
AJP-Port: ${ajp_port}
Shutdown-Port: ${shutdown_port}",
    owner => $tomcat_user,
    group => users,
    require => Exec ["extract_${inst_dir}"],
  }


  ################################
  #                              #
  #     Installation Wrapper     #
  #                              #
  ################################

  # download and extract wrapper archive

  exec { "download_wrapper_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/usr/src",
    command => "wget -O ${pkg_wrapper}.tar.gz ${download_url_wrapper}",
    creates => "/usr/src/${pkg_wrapper}.tar.gz",
  }

  exec { "extract_wrapper_${inst_dir}":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    cwd => "/usr/src",
    command => "tar -xzf /usr/src/${pkg_wrapper}.tar.gz",
    creates => "/usr/src/${pkg_wrapper}/bin",
    require => Exec [ "download_wrapper_${inst_dir}" ],
  }

  # copy wrapper files into tomcat installation directory
  
  exec { "${inst_dir}/${pkg_tomcat}/bin/wrapper":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp /usr/src/${pkg_wrapper}/bin/wrapper ${inst_dir}/${pkg_tomcat}/bin/wrapper",
    user => $tomcat_user,
    creates => "${inst_dir}/${pkg_tomcat}/bin/wrapper",
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }       
  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp /usr/src/${pkg_wrapper}/lib/libwrapper.so ${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
    user => $tomcat_user,
    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }       
  exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar":
    path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    command => "cp /usr/src/${pkg_wrapper}/lib/wrapper.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
    user => $tomcat_user,
    creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }       
  file { "${inst_dir}/${pkg_tomcat}/bin/tomcat-wrapper.sh":
    # deploy own tomcat-wrapper start script
    content => template('tomcats/tomcat-wrapper.sh.erb'),
    owner => $tomcat_user,
    group => 'users',
    mode => 0755,
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  
  # deploy wrapper configuration
         
  file { "${inst_dir}/${pkg_tomcat}/conf/wrapper.conf":
    content => template('tomcats/wrapper.conf.erb'),
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/${pkg_tomcat}/conf/wrapper-custom.conf":
    content => template('tomcats/wrapper-custom.conf.erb'),
    replace => false,
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }

  # Overwrite default tomcat startup and shutdown script with custom scripts
  
  file { "${inst_dir}/${pkg_tomcat}/bin/startup.sh":
    content => template('tomcats/startup.sh.erb'),
    owner => $tomcat_user,
    group => 'users',
    mode => 0755,
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh":
    content => template('tomcats/shutdown.sh.erb'),
    owner => $tomcat_user,
    group => 'users',
    mode => 0755,
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }

  # deploy Linux init-Script
  
  file { "/etc/init.d/tomcat${tomcat_number}":
    content => template('tomcats/initscript.erb'),
    owner => $tomcat_user,
    group => 'users',
    mode => 0755,
    require => File [ "${inst_dir}/${pkg_tomcat}/bin/startup.sh" ],
  }

  # symlinks im tomcat homedir (if available)

  file { "/home/${tomcat_user}/tomcat${tomcat_number}":
    ensure => link,
    target => "$inst_dir",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/logs":
    ensure => link,
    target => "$inst_dir/$pkg_tomcat/logs",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/webapps":
    ensure => link,
    target => "$inst_dir/$pkg_tomcat/webapps",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/startup.sh":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/bin/startup.sh",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/shutdown.sh":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }
  file { "${inst_dir}/wrapper.log":
    ensure => link,
    target => "${inst_dir}/${pkg_tomcat}/logs/wrapper.log",
    owner => $tomcat_user,
    group => 'users',
    require => Exec [ "extract_wrapper_${inst_dir}" ],
  }


  ################################
  #                              #
  #     Restart after update     #
  #                              #
  ################################


  # Restart service after tomcat update or wrapper update or configuration restore
#	exec { "restart_${inst_dir}":
#		command => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh && ${inst_dir}/${pkg_tomcat}/bin/startup.sh",
#		user => $tomcat_user,
#		subscribe => [ tomcats::install_tomcat ["${inst_dir}"], tomcat::install_wrapper ["${inst_dir}/${pkg_tomcat}"]],
#		refreshonly => true,
#	}


#	service { "tomcat${tomcat_number}":
#		ensure => running,
#	}


}