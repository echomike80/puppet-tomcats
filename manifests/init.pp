class tomcats {

  # system user for tomcat service
	user { 'tomcat':
		ensure => present,
		comment => 'system user for tomcat',
		home => '/home/tomcat',
		managehome => true,
		uid => '3002',
		gid => '100',
		shell => '/bin/bash',
		password => '$6$WTIzKbqC$dvQe9Bh.IxG0vVo/ILeMvHIuLg4eKd3FyhKHRxOCxuGGsr8WY.GkFh/oEdngC3HmN26.H7o334f/XLja6Hrf0.',
	}

  # tomcat installation directory
	file { '/srv/tomcat':
		ensure => directory,
	}

  # tomcat package directory
	file { '/srv/tomcat/src':
		ensure => directory,
		owner => tomcat,
		require => File [ '/srv/tomcat' ],
	}

  # readme file in package directoy
	file { '/srv/tomcat/src/_important.txt':
		ensure => present,
		content => "# Directory managed by puppet
Do not delete anything here! Thx.",
		owner => tomcat,
		require => File [ '/srv/tomcat/src' ],
	}
}


