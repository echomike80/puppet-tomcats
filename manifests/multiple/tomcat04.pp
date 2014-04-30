class tomcats::multiple::tomcat04 (
  $tomcat_release = $tomcats::params::default_tomcat_release,
  $java_home = $tomcats::params::default_java_home,
  $download_tomcat_from = $tomcats::params::default_download_tomcat_from,
  $download_wrapper_from = $tomcats::params::default_download_wrapper_from,
  $tomcat_user = $tomcats::params::default_tomcat_user,
  $tomcat_locales = $tomcats::params::default_tomcat_locales,
) {
  
  # load tomcat default stuff like system user, group, etc
  require tomcats
  
  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  include tomcats::params

  # variables that cannot be used as parameters
  $tomcat_number = 04
  $wrapper_release = $tomcats::params::default_wrapper_release

  # load resource type install with all parameters
  tomcats::install { "${tomcat_number}": 
    tomcat_number => $tomcat_number,
    tomcat_release => $tomcat_release,
    wrapper_release => $wrapper_release,
    java_home => $java_home,
    download_tomcat_from => $download_tomcat_from,
    download_wrapper_from => $download_wrapper_from,
    tomcat_user => $tomcat_user,
    tomcat_locales => $tomcat_locales,
  }
}