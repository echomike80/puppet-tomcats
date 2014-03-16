# declare classes in your site.pp or ENC

class { profile::tomcat01:
  # override parameters here:
  profile_download_from => 'lsus.ecg-leipzig.de',
}
class { profile::tomcat02:
  # override parameters here:
  profile_tomcat_release => '5.5.36',
  profile_download_from => 'lsus.echomike.de',
}

#############################################################

# define your custom profile class (role) in your own modules

class profile::tomcat01 (
  $profile_tomcat_release = undef,
  $profile_java_home = undef,
  $profile_download_from = undef,
  $profile_tomcat_user = undef,
  $profile_tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat01:
      class_tomcat_release => $profile_tomcat_release,
      class_java_home => $profile_java_home,
      class_download_from => $profile_download_from,
      class_tomcat_user => $profile_tomcat_user,
      class_tomcat_locales => $profile_tomcat_locales,
    }
}

class profile::tomcat02 (
  $profile_tomcat_release = undef,
  $profile_java_home = undef,
  $profile_download_from = undef,
  $profile_tomcat_user = undef,
  $profile_tomcat_locales = undef,
)  {
    class { tomcats::multiple::tomcat02:
      class_tomcat_release => $profile_tomcat_release,
      class_java_home => $profile_java_home,
      class_download_from => $profile_download_from,
      class_tomcat_user => $profile_tomcat_user,
      class_tomcat_locales => $profile_tomcat_locales,
    }
}
