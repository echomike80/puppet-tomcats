# declare classes in your site.pp or ENC

class { profile::tomcat01:
  # override parameters here:
  profile_download_tomcat_from => 'http://lsus.ecg-leipzig.de',
  # profile_download_wrapper_from => 'http://lsus.ecg-leipzig.de/dist/java-wrapper',
}
class { profile::tomcat02:
  # override parameters here:
  profile_tomcat_release => '5.5.36',
}

#############################################################

# define your custom profile class (role) in your own modules

class profile::tomcat01 (
  $profile_tomcat_release = undef,
  $profile_java_home = undef,
  $profile_download_tomcat_from = undef,
  $profile_download_wrapper_from = undef,
  $profile_tomcat_user = undef,
  $profile_tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat01:
      class_tomcat_release => $profile_tomcat_release,
      class_java_home => $profile_java_home,
      class_download_tomcat_from => $profile_download_tomcat_from,
      class_download_wrapper_from => $profile_download_wrapper_from,
      class_tomcat_user => $profile_tomcat_user,
      class_tomcat_locales => $profile_tomcat_locales,
    }
}

class profile::tomcat02 (
  $profile_tomcat_release = undef,
  $profile_java_home = undef,
  $profile_download_tomcat_from = undef,
  $profile_download_wrapper_from = undef,
  $profile_tomcat_user = undef,
  $profile_tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat02:
      class_tomcat_release => $profile_tomcat_release,
      class_java_home => $profile_java_home,
      class_download_tomcat_from => $profile_download_tomcat_from,
      class_download_wrapper_from => $profile_download_wrapper_from,
      class_tomcat_user => $profile_tomcat_user,
      class_tomcat_locales => $profile_tomcat_locales,
    }
}
