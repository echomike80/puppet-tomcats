# declare classes in your site.pp or ENC

class { profile::win_tomcat01:
  # override parameters here:
  download_tomcat_from => '\\192.168.1.9\softwaredistribution',
  download_wrapper_from => '\\192.168.1.9\softwaredistribution',
}
class { profile::win_tomcat02:
  # override parameters here:
  tomcat_release => '5.5.36',
  download_tomcat_from => '\\192.168.1.9\softwaredistribution',
  download_wrapper_from => '\\192.168.1.9\softwaredistribution',
}

#############################################################

# define your custom profile class (role) in your own modules

class profile::win_tomcat01 (
  $tomcat_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $tomcat_locales = undef,
  $parent_inst_dir = undef,
)  {
    class { windows_tomcats::multiple::tomcat01:
      tomcat_release => $tomcat_release,
      java_home => $java_home,
      download_tomcat_from => $download_tomcat_from,
      download_wrapper_from => $download_wrapper_from,
      tomcat_locales => $tomcat_locales,
	  parent_inst_dir => $parent_inst_dir,
    }
}

class profile::win_tomcat02 (
  $tomcat_release = undef,
  $java_home = undef,
  $download_tomcat_from = undef,
  $download_wrapper_from = undef,
  $tomcat_locales = undef,
  $parent_inst_dir = undef,
)  {
    class { windows_tomcats::multiple::tomcat02:
      tomcat_release => $tomcat_release,
      java_home => $java_home,
      download_tomcat_from => $download_tomcat_from,
      download_wrapper_from => $download_wrapper_from,
      tomcat_locales => $tomcat_locales,
	  parent_inst_dir => $parent_inst_dir,
    }
}
