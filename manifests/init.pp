class tomcats {

  # system user for tomcat service
	user { 'tomcat':
		ensure => present,
#		comment => 'ECG Tomcat Funktionsnutzer',
#		home => '/home/tomcat',
#		managehome => true,
#		uid => '3002',
#		gid => '100',
#		shell => '/bin/bash',
#		password => '$6$WTIzKbqC$dvQe9Bh.IxG0vVo/ILeMvHIuLg4eKd3FyhKHRxOCxuGGsr8WY.GkFh/oEdngC3HmN26.H7o334f/XLja6Hrf0.',
	}

  # tomcat installation directory
	file { '/srv/tomcat':
		ensure => directory,
	}

  # local directory for tomcat and wrapper archive downloads 
	file { '/usr/src':
		ensure => directory,
	}

}


