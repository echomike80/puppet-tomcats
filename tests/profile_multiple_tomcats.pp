# declare classes in your site.pp or ENC

class { profile::tomcat01:
  # override parameters here:
  download_tomcat_from => 'http://lsus.ecg-leipzig.de',
  # profile_download_wrapper_from => 'http://lsus.ecg-leipzig.de/dist/java-wrapper',
}
class { profile::tomcat02:
  # override parameters here:
  tomcat_release => '5.5.36',
}

#############################################################

# define your custom profile class (role) in your own modules

class profile::tomcat01 (
  $tomcat_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $tomcat_user = undef,
  $tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat01:
      tomcat_release => $tomcat_release,
      java_home => $java_home,
      download_tomcat_from => $download_tomcat_from,
      download_wrapper_from => $download_wrapper_from,
      tomcat_user => $tomcat_user,
      tomcat_locales => $tomcat_locales,
    }
}

class profile::tomcat02 (
  $tomcat_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $tomcat_user = undef,
  $tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat02:
      tomcat_release => $tomcat_release,
      java_home => $java_home,
      download_tomcat_from => $download_tomcat_from,
      download_wrapper_from => $download_wrapper_from,
      tomcat_user => $tomcat_user,
      tomcat_locales => $tomcat_locales,
    }
}
