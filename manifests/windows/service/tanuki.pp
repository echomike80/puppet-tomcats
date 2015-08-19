define tomcats::windows::service::tanuki (
  $tomcat_number           = undef,
  $tomcat_home             = undef,
  $tomcat_description      = undef,
  $lib_path                = undef,
  $install_tempdir_windows = 'C:\Windows\Temp',
  $wrapper_release         = undef,
  $java_home               = undef,
  $jmx_port                = undef,
  $download_wrapper_from   = undef,
  $autostart               = undef,) {
  # Define wrapper package
  case $::architecture {
    x86 : { $pkg_wrapper = "wrapper-windows-x86-32-${wrapper_release}" }
    x64 : { $pkg_wrapper = "wrapper-windows-x86-64-${wrapper_release}-st" }
  }

  # get archive and put it in tmp dir
  exec { "download_wrapper_${tomcat_home}":
    command  => "(new-object System.Net.WebClient).DownloadFile('${download_wrapper_from}', '${install_tempdir_windows}\\${pkg_wrapper}.zip')",
    provider => powershell,
    creates  => "${install_tempdir_windows}\\${pkg_wrapper}.zip",
  } ->
  # unzip archive into target dir and do not overwrite existing files (for example static/ content)
  exec { "extract_wrapper_${tomcat_home}":
    command  => "(new-object -com shell.application).namespace('${install_tempdir_windows}').CopyHere((new-object -com shell.application).namespace('${install_tempdir_windows}\\${pkg_wrapper}.zip').Items(),16)",
    provider => powershell,
    creates  => "${install_tempdir_windows}\\${pkg_wrapper}\\bin",
    require  => Exec["download_wrapper_${tomcat_home}"],
  }

  # copy wrapper files into tomcat installation directory
  # wrapper doc - http://wrapper.tanukisoftware.com/doc/english/integrate-start-stop-win.html
  exec { "${tomcat_home}\\bin\\wrapper.exe":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\bin\\wrapper.exe ${tomcat_home}\\bin\\wrapper.exe",
    creates => "${tomcat_home}\\bin\\wrapper.exe",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  exec { "${tomcat_home}\\bin\\Tomcat.bat":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\src\\bin\\App.bat.in ${tomcat_home}\\bin\\Tomcat.bat",
    creates => "${tomcat_home}\\bin\\Tomcat.bat",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  exec { "${tomcat_home}\\bin\\InstallTomcat-NT.bat":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\src\\bin\\InstallApp-NT.bat.in ${tomcat_home}\\bin\\InstallTomcat-NT.bat",
    creates => "${tomcat_home}\\bin\\InstallTomcat-NT.bat",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  exec { "${tomcat_home}\\bin\\UninstallTomcat-NT.bat":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\src\\bin\\UninstallApp-NT.bat.in ${tomcat_home}\\bin\\UninstallTomcat-NT.bat",
    creates => "${tomcat_home}\\bin\\UninstallTomcat-NT.bat",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  exec { "${tomcat_home}\\${lib_path}\\wrapper.dll":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\lib\\wrapper.dll ${tomcat_home}\\${lib_path}\\wrapper.dll",
    creates => "${tomcat_home}\\${lib_path}\\wrapper.dll",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  exec { "${tomcat_home}\\${lib_path}\\wrapper.jar":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\lib\\wrapper.jar ${tomcat_home}\\${lib_path}\\wrapper.jar",
    creates => "${tomcat_home}\\${lib_path}\\wrapper.jar",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  # deploy wrapper licence
  exec { "${tomcat_home}\\conf\\wrapper-license.conf":
    command => "cmd.exe /c copy ${install_tempdir_windows}\\${pkg_wrapper}\\conf\\wrapper-license.conf ${tomcat_home}\\conf\\wrapper-license.conf",
    creates => "${tomcat_home}\\conf\\wrapper-license.conf",
    require => Exec["extract_wrapper_${tomcat_home}"],
    before  => Exec["install_service_wrapper_${tomcat_home}"],
  }

  # deploy wrapper configuration (after copy wrapper files into tomcat installation directory)
  file { "${tomcat_home}\\conf\\wrapper.conf":
    content            => template('tomcats/windows/tanuki-wrapper.conf.erb'),
    replace            => false,
    source_permissions => ignore,
    require            => Exec["extract_wrapper_${tomcat_home}"],
    before             => Exec["install_service_wrapper_${tomcat_home}"],
  }

  # register wrapper as windows service and create logfile
  exec { "install_service_wrapper_${tomcat_home}":
    path    => "${tomcat_home}\\bin",
    command => "${tomcat_home}\\bin\\InstallTomcat-NT.bat",
    creates => "${tomcat_home}\\bin\\InstallTomcat-NT.log",
  }

  file { "${tomcat_home}\\bin\\InstallTomcat-NT.log":
    ensure             => present,
    content            => "# File managed by puppet
Wrapper registered as Windows service \"Tomcat${tomcat_home}\"",
    source_permissions => ignore,
    require            => Exec["install_service_wrapper_${tomcat_home}"],
  }
}
