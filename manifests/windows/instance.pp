class tomcats::windows::instance (
  $tomcat_instances          = {
    # these values you will see as default in your ENC like The Foreman
    instance01 => {
      tomcat_number   => '01',
      tomcat_release  => '7.0.54',
      java_home       => 'C:\Program Files\Java\jdk8',
      parent_inst_dir => 'C:\Program Files',
    }
    ,
  }
  ,
  $tomcat_instances_defaults = {
    tomcat_number         => '01',
    tomcat_release        => '7.0.54',
    wrapper_release       => '3.5.21',
    java_home             => 'C:\Program Files\Java\jdk8',
    parent_inst_dir       => 'C:\Program Files',
    download_tomcat_from  => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54-windows-x64.zip',
    wrapper               => 'none',
    wrapper_release       => '11.11',
    download_wrapper_from => 'http://downloads.sourceforge.net/project/yajsw/yajsw/yajsw-stable-11.11/yajsw-stable-11.11.zip',
    autostart             => true,
  }
  ,) {
  # load tomcat default configuration parameters, which are used when no parameters are set (undef)
  require tomcats::windows::params

  # call tomcats::windows::install define to configure each tomcat instance
  create_resources(tomcats::windows::install, $tomcat_instances, $tomcat_instances_defaults)

}
