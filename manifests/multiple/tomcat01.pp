class tomcats::multiple::tomcat01 (
  $class_tomcat_number = 01,
  $class_tomcat_release = undef,
  $class_java_home = undef,
  $class_download_from = undef,
  $class_tomcat_user = undef,
  $class_tomcat_locales = undef,
) {
  
  # load tomcat default stuff like system user, group, etc
  require tomcats
  
  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  include tomcats::params
  
  # set tomcat default configuration parameters, if not already set
  if $class_tomcat_release == undef {
        $tomcat_release = $tomcats::params::default_tomcat_release
      }
  else { 
        $tomcat_release = $class_tomcat_release
      }
  if $class_java_home == undef {
        $java_home = $tomcats::params::default_java_home
      }
  else { 
        $java_home = $class_java_home
      }
  if $class_download_from == undef {
        $download_from = $tomcats::params::default_download_from
      }
  else { 
        $download_from = $class_download_from
      }
  if $class_tomcat_user == undef {
        $tomcat_user = $tomcats::params::default_tomcat_user
      }
  else { 
        $tomcat_user = $class_tomcat_user
      }
  if $class_tomcat_locales == undef {
        $tomcat_locales = $tomcats::params::default_tomcat_locales
      }
  else { 
        $tomcat_locales = $class_tomcat_locales
      }
      
  $tomcat_number = $class_tomcat_number
  
  # load resource type install_init with all parameters
  tomcats::install { "$tomcat_number": 
    tomcat_number => $tomcat_number,
    tomcat_release => $tomcat_release,
    java_home => $java_home,
    download_from => $download_from,
    tomcat_user => $tomcat_user,
    tomcat_locales => $tomcat_locales,
  }
}