define tomcats::tomcat ($majorversion, $tomcat_release, $tomcat_user, $pkg_tomcat, $inst_dir, $download_url, $http_port, $shutdown_port, $ajp_port) {

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

	exec { "unpack_${inst_dir}":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		command => "tar --directory ${inst_dir}/${pkg_tomcat} --strip-components=1 -xzf /usr/src/apache-tomcat-${tomcat_release}.tar.gz",
		user => $tomcat_user,
		unless => "grep ${tomcat_release} ${inst_dir}/${pkg_tomcat}/RELEASE-NOTES",
		require => [ Exec[ "download_${inst_dir}" ], File[ "${inst_dir}/${pkg_tomcat}" ] ],
	}

	file { [ "${inst_dir}/${pkg_tomcat}/webapps/docs", "${inst_dir}/${pkg_tomcat}/webapps/examples", "${inst_dir}/${pkg_tomcat}/webapps/balancer", "${inst_dir}/${pkg_tomcat}/webapps/jsp-examples", "${inst_dir}/${pkg_tomcat}/webapps/servlets-examples", "${inst_dir}/${pkg_tomcat}/webapps/tomcat-docs", "${inst_dir}/${pkg_tomcat}/webapps/webdav" ]:
		ensure => absent,
		force => true,
		require => Exec ["unpack_${inst_dir}"],
	}

	file { "${inst_dir}/${pkg_tomcat}/conf/tomcat-users.xml":
		content => template("tomcats/tomcat-users.xml.erb"),
		owner => $tomcat_user,
		group => users,
		require => Exec ["unpack_${inst_dir}"],
	}

	file { "${inst_dir}/${pkg_tomcat}/conf/server.xml":
		content => template("tomcats/server${majorversion}.xml.erb"),
		owner => $tomcat_user,
		group => users,
		require => Exec ["unpack_${inst_dir}"],
	}

	case $majorversion {
		5: { $lib_path = "common/lib" }
		default: { $lib_path = "lib"}
	}

	# To-Do: Wenn sich der Oracle Client ändert wird die neue Lib nicht mehr kopiert
	# Umgebungsvariablen unter Linux müssen geschützt werden mit "\"
	exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		command => "cp \$ORACLE_HOME\/jdbc/lib/ojdbc6.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar",
		user => $tomcat_user,
		creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/ojdbc6.jar",
		require => Exec [ "unpack_${inst_dir}" ],
	}       

	file { "${inst_dir}/ports.txt":
		ensure => present,
		content => "# File managed by puppet

HTTP-Port: ${http_port}
AJP-Port: ${ajp_port}
Shutdown-Port: ${shutdown_port}",
		owner => $tomcat_user,
		group => users,
		require => Exec ["unpack_${inst_dir}"],
	}

}
