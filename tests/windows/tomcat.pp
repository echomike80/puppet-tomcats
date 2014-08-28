# use roles and profiles and declare classes in your site.pp or ENC

class profile::windows::tomcat (
  $tomcat_instances = {
    # these values you will see as default in your ENC like The Foreman
    instance01 => {
      tomcat_number => '01',
      tomcat_release => '5.5.36',
      java_home => "C:\\Program Files\\Java\\jdk6",
      parent_inst_dir => "C:\\Program Files",
    },
  },
  $tomcat_instances_defaults = {
      # these values are taken if you won't specify values in your ENC like The Foreman
      tomcat_number => '01',
      tomcat_release => '7.0.54',
      wrapper_release => '3.5.21',
      java_home => "C:\\Program Files\\Java\\jdk6",
      parent_inst_dir => "C:\\Program Files",
      download_tomcat_from => "\\\\puppet\\softwaredistribution",
      download_wrapper_from => "\\\\puppet\\softwaredistribution",
      path_to_7zip => "C:\\Program Files\\7-Zip",
  },
) {

  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  require tomcats::windows::params

  # call tomcats::windows::install define to configure each tomcat instance
  create_resources(tomcats::windows::install, $tomcat_instances, $tomcat_instances_defaults)

}
