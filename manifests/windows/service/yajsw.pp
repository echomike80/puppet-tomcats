define tomcats::windows::service::yajsw (
  $tomcat_number           = undef,
  $tomcat_home             = undef,
  $tomcat_description      = undef,
  $lib_path                = undef,
  $install_tempdir_windows = 'C:\Windows\Temp',
  $wrapper_release         = '11.11',
  $java_home               = undef,
  $jmx_port                = undef,
  $download_wrapper_from   = 'http://downloads.sourceforge.net/project/yajsw/yajsw/yajsw-stable-11.11/yajsw-stable-11.11.zip',
  $autostart               = undef,) {
  $ctl_file = "${tomcat_home}\\yajsw\\yajsw-${wrapper_release}.ctl"

  # convert tomcat and java path fpr wrapper.conf
  $tomcat_home_with_slashes = regsubst($tomcat_home, '\\', '/', 'G')
  $java_home_with_slashes = regsubst($java_home, '\\', '/', 'G')
  $lib_path_with_slashes = regsubst($lib_path, '\\', '/', 'G')

  # get archive and put it in tmp dir
  exec { "download_wrapper_${tomcat_home}":
    command  => "(new-object System.Net.WebClient).DownloadFile('${download_wrapper_from}', '${install_tempdir_windows}\\yajsw-stable-${wrapper_release}.zip')",
    provider => powershell,
    creates  => "${install_tempdir_windows}\\yajsw-stable-${wrapper_release}.zip",
  }

  # remove old yajsw if existing (recursively and without prompting)
  exec { "remove_old_wrapper-${tomcat_home}":
    command => "cmd.exe /c if exist ${tomcat_home}\\yajsw rmdir /s /q ${tomcat_home}\\yajsw",
    creates => $ctl_file,
  } ->
  # unzip archive into target dir and do not overwrite existing files (for example static/ content)
  exec { "extract_wrapper_${tomcat_home}":
    command  => "(new-object -com shell.application).namespace('${tomcat_home}').CopyHere((new-object -com shell.application).namespace('${install_tempdir_windows}\\yajsw-stable-${wrapper_release}.zip').Items(),16)",
    provider => powershell,
    creates  => $ctl_file,
    require  => Exec["download_wrapper_${tomcat_home}"],
  } ->
  # rename extracted yajsw-stable-${yajsw_release} directory into yajsw
  exec { "rename_wrapper_${tomcat_home}":
    cwd     => $tomcat_home,
    command => "cmd.exe /c if exist ${tomcat_home}\\yajsw-stable-${wrapper_release} ren yajsw-stable-${wrapper_release} yajsw",
    creates => $ctl_file,
  } ->
  # deploy version ctl file
  file { $ctl_file:
    ensure  => present,
    content => "# File managed by puppet - do not delete \r\n
YAJSW ${wrapper_release}",
  }

  # clean default wrapper.conf subscribes the ctl file
  exec { "clean_default_wrapper_conf_${tomcat_number}":
    cwd         => "${tomcat_home}\\yajsw\\conf",
    command     => "cmd.exe /c if exist wrapper.conf del wrapper.conf",
    refreshonly => true,
    subscribe   => File[$ctl_file],
    before      => File["${tomcat_home}\\yajsw\\conf\\wrapper.conf"],
  }
  # deploy wrapper configuration (after copy wrapper files into tomcat installation directory)
  file { "${tomcat_home}\\yajsw\\conf\\wrapper.conf":
    content            => template('tomcats/windows/yajsw-wrapper.conf.erb'),
    replace            => false,
    source_permissions => ignore,
    require            => File[$ctl_file],
  } ->
  # register wrapper as windows service
  exec { "install_service_wrapper_${tomcat_home}":
    path    => "${java_home}\\bin",
    command => "${tomcat_home}\\yajsw\\bat\\installService.bat",
    creates => "${tomcat_home}\\yajsw\\bat\\installService.log",
  } ->
  file { "${tomcat_home}\\yajsw\\bat\\installService.log":
    ensure             => present,
    content            => "# File managed by puppet
Wrapper registered as Windows service \"Tomcat${tomcat_number}\"",
    source_permissions => ignore,
    require            => Exec["install_service_wrapper_${tomcat_home}"],
  }
}
