class tomcats::instance (
  $tomcat_instances          = {
    # these values you will see as default in your ENC like The Foreman
    instance01 => {
      tomcat_number  => '01',
      tomcat_release => '7.0.54',
      java_home      => '/usr/lib/jvm/jdk-8-oracle-x64',
    }
    ,
  }
  ,
  $tomcat_instances_defaults = {
    tomcat_number        => '01',
    tomcat_release       => '7.0.54',
    wrapper_release      => '3.5.21',
    java_home            => '/usr/lib/jvm/jdk-8-oracle-x64',
    download_url_tomcat  => 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54.tar.gz',
    download_url_wrapper => 'http://lsus.ecg-leipzig.de/dist/java-wrapper/releases/3.5.21/wrapper-linux-x86-64-3.5.21.tar.gz',
  }
  ,) {
  # load tomcat default stuff like system user, group, etc
  require tomcats

  # call tomcats::install define to configure each tomcat instance
  create_resources(tomcats::install, $tomcat_instances, $tomcat_instances_defaults)

}
