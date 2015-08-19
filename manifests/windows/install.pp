# tomcats::windows::install resource will be used by multiple/tomcatxx.pp classes

define tomcats::windows::install (
  $tomcat_number           = undef,
  $tomcat_release          = undef,
  $parent_inst_dir         = undef,
  $tomcat_description      = undef,
  $install_tempdir_windows = 'C:\Windows\Temp',
  $wrapper                 = 'none',
  $wrapper_release         = undef,
  $java_home               = undef,
  $download_tomcat_from    = undef,
  $download_wrapper_from   = undef,
  $autostart               = undef,) {
  ################################################
  #                                              #
  #   Definition of variables for installation   #
  #                                              #
  ################################################

  Exec {
    path => 'C:\Windows\System32' }

  # Extract major version from tomcat_release
  $majorversion = regsubst($tomcat_release, '^(\d+)\.(\d+)\.(\d+)$', '\1')

  case $majorversion {
    5       : { $lib_path = "common\\lib" }
    default : { $lib_path = "lib" }
  }

  # Extract minor version from tomcat_release
  $minorversion = regsubst($tomcat_release, '^(\d+)\.(\d+)\.(\d+)$', '\2')

  # Define tomcat package version (i.e. apache-tomcat-7.0)
  $pkg_tomcat = "apache-tomcat-${majorversion}.${minorversion}"

  # Define tomcat ports
  case $tomcat_number {
    01, 1   : {
      $http_port = '8080'
      $shutdown_port = '8005'
      $ajp_port = '8009'
      $jmx_port = '9017'
    }
    02, 2   : {
      $http_port = '8090'
      $shutdown_port = '8006'
      $ajp_port = '8010'
      $jmx_port = '9018'
    }
    03, 3   : {
      $http_port = '8091'
      $shutdown_port = '8007'
      $ajp_port = '8011'
      $jmx_port = '9019'
    }
    04, 4   : {
      $http_port = '8092'
      $shutdown_port = '8008'
      $ajp_port = '8012'
      $jmx_port = '9020'
    }
    05, 5   : {
      $http_port = '8093'
      $shutdown_port = '8013'
      $ajp_port = '8014'
      $jmx_port = '9021'
    }
    06, 6   : {
      $http_port = '8094'
      $shutdown_port = '8015'
      $ajp_port = '8016'
      $jmx_port = '9022'
    }
    07, 7   : {
      $http_port = '8095'
      $shutdown_port = '8017'
      $ajp_port = '8018'
      $jmx_port = '9023'
    }
    08, 8   : {
      $http_port = '8096'
      $shutdown_port = '8019'
      $ajp_port = '8020'
      $jmx_port = '9024'
    }
    09, 9   : {
      $http_port = '8097'
      $shutdown_port = '8021'
      $ajp_port = '8022'
      $jmx_port = '9025'
    }
    # Dynamic port number generation from tomcat 10 and higher
    default : {
      $http_port = "9${tomcat_number}0"
      $shutdown_port = "9${tomcat_number}1"
      $ajp_port = "9${tomcat_number}2"
      $jmx_port = "9${tomcat_number}3"
    }
  }

  # Define tomcat[xx] installation directory
  if $tomcat_description != undef {
    $inst_dir = "${parent_inst_dir}\\Tomcat${tomcat_number}_${tomcat_description}"
  } else {
    $inst_dir = "${parent_inst_dir}\\Tomcat${tomcat_number}"
  }

  # Define tomcat package file name
  case $majorversion {
    5       : { $pkg_tomcat_filename = "apache-tomcat-${tomcat_release}" }
    default : { $pkg_tomcat_filename = "apache-tomcat-${tomcat_release}-windows-${architecture}" }
  }

  ###############################
  #                             #
  #     Installation Tomcat     #
  #                             #
  ###############################

  # tomcat[xx] installation directory with mkdir, because of ATLAS Deployment with deeper directory structure
  exec { "create_directory_${tomcat_number}":
    command => "cmd.exe /c mkdir ${inst_dir}\\${pkg_tomcat}",
    creates => "${inst_dir}\\${pkg_tomcat}",
  }

  # get archive and put it in tmp dir
  exec { "download_tomcat_${tomcat_number}":
    command  => "(new-object System.Net.WebClient).DownloadFile('${download_tomcat_from}', '${install_tempdir_windows}\\${pkg_tomcat_filename}.zip')",
    provider => powershell,
    creates  => "${install_tempdir_windows}\\${pkg_tomcat_filename}.zip",
    require  => Exec["create_directory_${tomcat_number}"],
  }

  # unzip archive into target dir and do not overwrite existing files (for example static/ content)
  exec { "extract_tomcat_source_${tomcat_number}":
    command  => "(new-object -com shell.application).namespace('${install_tempdir_windows}').CopyHere((new-object -com shell.application).namespace('${install_tempdir_windows}\\${pkg_tomcat_filename}.zip').Items(),16)",
    provider => powershell,
    creates  => "${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\bin",
    require  => Exec["download_tomcat_${tomcat_number}"],
  }

  exec { "clean_tomcat_source_conf_${tomcat_number}":
    cwd         => "${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\conf",
    command     => "cmd.exe /c if exist context.xml del catalina.properties context.xml server.xml tomcat-users.xml web.xml",
    refreshonly => true,
    subscribe   => Exec["extract_tomcat_source_${tomcat_number}"],
  }

  case $majorversion {
    5       : {
      exec { "clean_tomcat_source_webapps_${tomcat_number}":
        cwd         => "${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\webapps",
        command     => "cmd.exe /c if exist ROOT rmdir /s /q ROOT balancer jsp-examples servlets-examples tomcat-docs webdav",
        refreshonly => true,
        subscribe   => Exec["clean_tomcat_source_conf_${tomcat_number}"],
      }
    }
    # for tomcat 7
    default : {
      exec { "clean_tomcat_source_webapps_${tomcat_number}":
        cwd         => "${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\webapps",
        command     => "cmd.exe /c if exist ROOT rmdir /s /q ROOT docs examples",
        refreshonly => true,
        subscribe   => Exec["clean_tomcat_source_conf_${tomcat_number}"],
      }
    }
  }

  # xcopy extracted directory (i.e. apache-tomcat-7.0.52) to ${inst_dir}\\${pkg_tomcat}-directory (i.e. apache-tomcat-7.0)
  # xcopy doc - http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/xcopy.mspx?mfr=true
  exec { "xcopy_tomcat_${inst_dir}":
    command => "cmd.exe /c xcopy ${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\*.* ${inst_dir}\\${pkg_tomcat}\\ /e /s /h",
    creates => "${inst_dir}\\${pkg_tomcat}\\bin",
    require => Exec["clean_tomcat_source_webapps_${tomcat_number}"],
  }

  # copy tomcat5.exe and tcnative-1.dll into bin dir, if tomcat5 and x64 architecture
  if ($majorversion == '5') and ($::architecture == 'x64') {
    exec { "copy_tcnative_${inst_dir}":
      command     => "cmd.exe /c copy ${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\bin\\x64\\tcnative-1.dll ${inst_dir}\\${pkg_tomcat}\\bin\\",
      refreshonly => true,
      subscribe   => Exec["xcopy_tomcat_${inst_dir}"],
    }

    exec { "copy_tomcat5exe_${inst_dir}":
      command     => "cmd.exe /c copy ${install_tempdir_windows}\\apache-tomcat-${tomcat_release}\\bin\\x64\\tomcat5.exe ${inst_dir}\\${pkg_tomcat}\\bin\\",
      refreshonly => true,
      subscribe   => Exec["xcopy_tomcat_${inst_dir}"],
    }
  }

  file { "${inst_dir}\\${pkg_tomcat}\\conf\\tomcat-users.xml":
    content            => template("tomcats/common/tomcat-users.xml.erb"),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\${pkg_tomcat}\\conf\\catalina.properties":
    content            => template("tomcats/common/catalina.properties${majorversion}.erb"),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\${pkg_tomcat}\\conf\\context.xml":
    content            => template("tomcats/common/context${majorversion}.xml.erb"),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\${pkg_tomcat}\\conf\\server.xml":
    content            => template("tomcats/common/server${majorversion}.xml.erb"),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\${pkg_tomcat}\\conf\\web.xml":
    content            => template("tomcats/common/web${majorversion}.xml.erb"),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\${pkg_tomcat}\\${lib_path}\\ext":
    ensure  => directory,
    require => Exec["xcopy_tomcat_${inst_dir}"],
  }

  file { "${inst_dir}\\ports.txt":
    ensure             => present,
    content            => "# File managed by puppet \r\n
\r\n
HTTP-Port: ${http_port} \r\n
AJP-Port: ${ajp_port} \r\n
Shutdown-Port: ${shutdown_port} \r\n",
    source_permissions => ignore,
    require            => Exec["xcopy_tomcat_${inst_dir}"],
  }

  case $wrapper {
    'yajsw'  : {
      tomcats::windows::service::yajsw { $tomcat_number:
        tomcat_number           => $tomcat_number,
        tomcat_home             => "${inst_dir}\\${pkg_tomcat}",
        tomcat_description      => $tomcat_description,
        lib_path                => $lib_path,
        install_tempdir_windows => $install_tempdir_windows,
        wrapper_release         => $wrapper_release,
        java_home               => $java_home,
        jmx_port                => $jmx_port,
        download_wrapper_from   => $download_wrapper_from,
        autostart               => $autostart,
        require                 => File["${inst_dir}\\ports.txt"],
      }
    }
    'tanuki' : {
      tomcats::windows::service::tanuki { $tomcat_number:
        tomcat_number           => $tomcat_number,
        tomcat_home             => "${inst_dir}\\${pkg_tomcat}",
        tomcat_description      => $tomcat_description,
        lib_path                => $lib_path,
        install_tempdir_windows => $install_tempdir_windows,
        wrapper_release         => $wrapper_release,
        java_home               => $java_home,
        jmx_port                => $jmx_port,
        download_wrapper_from   => $download_wrapper_from,
        autostart               => $autostart,
        require                 => File["${inst_dir}\\ports.txt"],
      }
    }
  }
}