define tomcats::install( $tomcat_release='7.0.47',
	$java_home='/usr/lib/jvm/j2sdk1.6-oracle',
	$download_from='lsus.ecg-leipzig.de',
	# Originalpfad fuer Tomcat # $download_from='archive.apache.org',
	$tomcat_user='tomcat',
	$tomcat_locales='de_DE@euro' ) {

	####################################
	# Definition notwendiger Variablen #
	####################################

	# Tomcat Basics laden (require = noch bevor anderer Code ausgeführt wird)
	require tomcats

	# Tomcat Nummer bestimmen (Eindeutiger Übergabeparameter der Definition)
	$tomcat_number = $name

	# Aus Tomcat Release die Major-Version extrahieren
	$majorversion = regsubst($tomcat_release,'^(\d+)\.(\d+)\.(\d+)$','\1')

	# Aus Tomcat Release die Minor-Version extrahieren
	$minorversion = regsubst($tomcat_release,'^(\d+)\.(\d+)\.(\d+)$','\2')

	# Paket-Version definieren
	$pkg_tomcat = "apache-tomcat-${majorversion}.${minorversion}"

	# Tomcat Installationsverzeichnis festlegen
	$inst_dir = "/srv/tomcat/tomcat${tomcat_number}"

	# Download-URL definieren
	$download_url = "http://${download_from}/dist/tomcat/tomcat-${majorversion}/v${tomcat_release}/bin/apache-tomcat-${tomcat_release}.tar.gz"

	# Tomcat Ports bestimmen
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
		# Ab Tomcat 10 werden die Ports dynamisch anhand der Tomcat-Nummer generiert
		default: {	$http_port = "9${tomcat_number}0"
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

	# Tomcat-Dateien über eine Definition ins Zielverzeichnis kopieren
	tomcats::tomcat { "${inst_dir}":
		majorversion => "${majorversion}",
		tomcat_release => "${tomcat_release}",
		tomcat_user => "${tomcat_user}",
		pkg_tomcat  => "${pkg_tomcat}",
		download_url => "${download_url}",
		inst_dir => "${inst_dir}",
		http_port => "${http_port}",
		shutdown_port => "${shutdown_port}",
		ajp_port => "${ajp_port}",
       }

	# Wrapper-Dateien über eine Definition ins Zielverzeichnis kopieren
	tomcats::wrapper { "${inst_dir}/${pkg_tomcat}":
		tomcat_number => "${tomcat_number}",
		majorversion => "${majorversion}",
		tomcat_user => "${tomcat_user}",
		pkg_tomcat  => "${pkg_tomcat}",
		pkg_wrapper => "${pkg_wrapper}",
		download_url_wrapper => "${download_url_wrapper}",
		inst_dir => "${inst_dir}",
		java_home => "${java_home}",
		tomcat_locales => "${tomcat_locales}",
		jmx_port => "${jmx_port}",
		require => tomcat::tomcat ["${inst_dir}"],
		before => Exec ["restart_${inst_dir}"],
	}

	# Nach einem Tomcat- oder Wrapper-Update sowie auch nach Wiederherstellung jeglicher fixer Konfiguration wird der Dienst neugestartet
	exec { "restart_${inst_dir}":
		command => "${inst_dir}/${pkg_tomcat}/bin/shutdown.sh && ${inst_dir}/${pkg_tomcat}/bin/startup.sh",
		user => $tomcat_user,
		subscribe => [ tomcat::tomcat ["${inst_dir}"], tomcat::wrapper ["${inst_dir}/${pkg_tomcat}"]],
		refreshonly => true,
	}


#	service { "tomcat${tomcat_number}":
#		ensure => running,
#	}


}
