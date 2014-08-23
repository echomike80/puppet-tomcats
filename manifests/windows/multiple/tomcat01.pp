class tomcats::windows::multiple::tomcat01 (
  $tomcat_number = 01,
  $tomcat_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $parent_inst_dir = undef,
  $path_to_7zip = undef,
  $autostart = undef,
) {

  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  include tomcats::windows::params

  # set tomcat default configuration parameters, if not already set
  if $tomcat_release == undef {
        $temp_tomcat_release = $tomcats::windows::params::default_tomcat_release
      }
  else {
        $temp_tomcat_release = $tomcat_release
      }

  if $java_home == undef {
        $temp_java_home = $tomcats::windows::params::default_java_home
      }
  else {
        $temp_java_home = $java_home
      }

  if $download_tomcat_from == undef {
        $temp_download_tomcat_from = $tomcats::windows::params::default_download_tomcat_from
      }
  else {
        $temp_download_tomcat_from = $download_tomcat_from
      }

  if $download_wrapper_from == undef {
        $temp_download_wrapper_from = $tomcats::windows::params::default_download_wrapper_from
      }
  else {
        $temp_download_wrapper_from = $download_wrapper_from
      }

  if $parent_inst_dir == undef {
        $temp_parent_inst_dir = $tomcats::windows::params::parent_inst_dir
      }
  else {
        $temp_parent_inst_dir = $parent_inst_dir
      }

  if $path_to_7zip == undef {
        $temp_path_to_7zip = $tomcats::windows::params::path_to_7zip
      }
  else {
        $temp_path_to_7zip = $path_to_7zip
      }
  if $autostart == undef {
        $temp_autostart = $tomcats::windows::params::autostart
      }
  else {
        $temp_autostart = $autostart
      }

  $temp_tomcat_number = $tomcat_number
  # fixed values in tomcats::windows:params
  $temp_wrapper_release = $tomcats::windows::params::default_wrapper_release

  # load resource type install with all parameters
  tomcats::windows::install { "$temp_tomcat_number": 
    tomcat_number => $temp_tomcat_number,
    tomcat_release => $temp_tomcat_release,
    parent_inst_dir => $temp_parent_inst_dir,
    wrapper_release => $temp_wrapper_release,
    java_home => $temp_java_home,
    download_tomcat_from => $temp_download_tomcat_from,
    download_wrapper_from => $temp_download_wrapper_from,
    path_to_7zip => $temp_path_to_7zip,
    autostart => $temp_autostart,
  }
}
