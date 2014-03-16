class tomcats::multiple::tomcat02 (
  $tomcat_number = 02,
  $tomcat_release = undef,
  # fixed wrapper release because of static tomcat-wrapper.sh in templates (future: augeas fix?)
  # $wrapper_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $tomcat_user = undef,
  $tomcat_locales = undef,
) {
  
  # load tomcat default stuff like system user, group, etc
  require tomcats
  
  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  include tomcats::params
  
  # set tomcat default configuration parameters, if not already set
  if $tomcat_release == undef {
        $temp_tomcat_release = $tomcats::params::default_tomcat_release
      }
  else { 
        $temp_tomcat_release = $tomcat_release
      }
  # fixed wrapper release 
  #if $wrapper_release == undef {
        $temp_wrapper_release = $tomcats::params::default_wrapper_release
  #    }
  #else { 
  #      $_wrapper_release = $wrapper_release
  #    }
  if $java_home == undef {
        $temp_java_home = $tomcats::params::default_java_home
      }
  else { 
        $temp_java_home = $java_home
      }
  if $download_tomcat_from == undef {
        $temp_download_tomcat_from = $tomcats::params::default_download_tomcat_from
      }
  else { 
        $temp_download_tomcat_from = $download_tomcat_from
      }
  if $download_wrapper_from == undef {
        $temp_download_wrapper_from = $tomcats::params::default_download_wrapper_from
      }
  else { 
        $temp_download_wrapper_from = $download_wrapper_from
      }
  if $tomcat_user == undef {
        $temp_tomcat_user = $tomcats::params::default_tomcat_user
      }
  else { 
        $temp_tomcat_user = $tomcat_user
      }
  if $tomcat_locales == undef {
        $temp_tomcat_locales = $tomcats::params::default_tomcat_locales
      }
  else { 
        $temp_tomcat_locales = $tomcat_locales
      }
      
  $temp_tomcat_number = $tomcat_number
  
  # load resource type install with all parameters
  tomcats::install { "$temp_tomcat_number": 
    tomcat_number => $temp_tomcat_number,
    tomcat_release => $temp_tomcat_release,
    wrapper_release => $temp_wrapper_release,
    java_home => $temp_java_home,
    download_tomcat_from => $temp_download_tomcat_from,
    download_wrapper_from => $temp_download_wrapper_from,
    tomcat_user => $temp_tomcat_user,
    tomcat_locales => $temp_tomcat_locales,
  }
}