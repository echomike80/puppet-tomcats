class tomcats::windows::params {

  # these values you can override with class multiple/tomcat[xx].pp
  $default_tomcat_release = "7.0.52"
  $default_java_home = "C:\\Program Files\\Java\\jdk1.6.0_45"
  $default_download_tomcat_from= "\\\\puppet\\softwaredistribtion"
  $default_download_wrapper_from = "\\\\puppet\\softwaredistribtion"
  $default_parent_inst_dir = "C:\\Program Files"
  $path_to_7zip = "C:\\Program Files\\7-Zip"

  # fixed value you can only here in this params-file
  $default_wrapper_release = "3.5.21"
  $default_tomcat_user = "tomcat"

}
