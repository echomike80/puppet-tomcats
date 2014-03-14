define tomcats::wrapper($tomcat_number, $majorversion, $tomcat_user, $inst_dir, $pkg_tomcat, $pkg_wrapper, $download_url_wrapper, $java_home, $tomcat_locales, $jmx_port) {

	case $majorversion {
		5: { $lib_path = "common/lib" }
		default: { $lib_path = "lib"}
	}

	exec { "download_wrapper_${inst_dir}":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		cwd => "/usr/src",
		command => "wget -O ${pkg_wrapper}.tar.gz ${download_url_wrapper}",
		creates => "/usr/src/${pkg_wrapper}.tar.gz",
	}

	exec { "unpack_wrapper_${inst_dir}":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		cwd => "/usr/src",
		command => "tar -xzf /usr/src/${pkg_wrapper}.tar.gz",
		creates => "/usr/src/${pkg_wrapper}/bin",
		require => Exec [ "download_wrapper_${inst_dir}" ],
	}

	# Wrapper-Dateien an Ort und Stelle kopieren
	exec { "${inst_dir}/${pkg_tomcat}/bin/wrapper":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		command => "cp /usr/src/${pkg_wrapper}/bin/wrapper ${inst_dir}/${pkg_tomcat}/bin/wrapper",
		user => $tomcat_user,
		creates => "${inst_dir}/${pkg_tomcat}/bin/wrapper",
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}       
	exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		command => "cp /usr/src/${pkg_wrapper}/lib/libwrapper.so ${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
		user => $tomcat_user,
		creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/libwrapper.so",
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}       
	exec { "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar":
		path => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
		command => "cp /usr/src/${pkg_wrapper}/lib/wrapper.jar ${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
		user => $tomcat_user,
		creates => "${inst_dir}/${pkg_tomcat}/${lib_path}/wrapper.jar",
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}       
	file { "${inst_dir}/${pkg_tomcat}/bin/tomcat-wrapper.sh":
		# Wir nehmen nicht das mitgelieferte Startscript, sondern ein eigenes Template!
		content => template('tomcats/tomcat-wrapper.sh.erb'),
		owner => $tomcat_user,
		group => 'users',
		mode => 0755,
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}       
	file { "${inst_dir}/${pkg_tomcat}/conf/wrapper.conf":
		content => template('tomcats/wrapper.conf.erb'),
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/${pkg_tomcat}/conf/wrapper-custom.conf":
		content => template('tomcats/wrapper-custom.conf.erb'),
		replace => false,
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}

	# Original Startup und Shutdown Scripte überschreiben mit Template
	file { "${inst_dir}/${pkg_tomcat}/bin/startup.sh":
		content => template('tomcats/startup.sh.erb'),
		owner => $tomcat_user,
		group => 'users',
                mode => 0755,
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh":
		content => template('tomcats/shutdown.sh.erb'),
		owner => $tomcat_user,
		group => 'users',
                mode => 0755,
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
        }

	# Init-Script
	file { "/etc/init.d/tomcat${tomcat_number}":
		content => template('tomcats/initscript.erb'),
		owner => $tomcat_user,
		group => 'users',
                mode => 0755,
	}

	# Softlinks im tomcat Homeverzeichnis
	file { "/home/${tomcat_user}/tomcat${tomcat_number}":
		ensure => link,
		target => "$inst_dir",
		owner => $tomcat_user,
		group => 'users',
		require => File [ "${inst_dir}" ],
	}
	file { "${inst_dir}/logs":
		ensure => link,
		target => "$inst_dir/$pkg_tomcat/logs",
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/webapps":
		ensure => link,
		target => "$inst_dir/$pkg_tomcat/webapps",
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/startup.sh":
		ensure => link,
		target => "${inst_dir}/${pkg_tomcat}/bin/startup.sh",
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/shutdown.sh":
		ensure => link,
		target => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh",
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}
	file { "${inst_dir}/wrapper.log":
		ensure => link,
		target => "${inst_dir}/${pkg_tomcat}/logs/wrapper.log",
		owner => $tomcat_user,
		group => 'users',
		require => Exec [ "unpack_wrapper_${inst_dir}" ],
	}

}
