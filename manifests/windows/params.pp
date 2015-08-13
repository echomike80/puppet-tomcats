class tomcats::windows::params {

  # these values you can override with class multiple/tomcat[xx].pp
  $default_tomcat_release = '7.0.54'
  $default_java_home = 'C:\Program Files\Java\jdk6'
  $default_download_tomcat_from= 'http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.54/bin/apache-tomcat-7.0.54-windows-x64.zip'
  $default_download_wrapper_from = 'http://wrapper.tanukisoftware.com/download/3.5.21/wrapper-windows-x86-64-3.5.21-st.zip'
  $default_parent_inst_dir = 'C:\Program Files'
  $autostart = true

  # fixed value you can only here in this params-file
  $default_wrapper_release = '3.5.21'
  $default_tomcat_user = 'tomcat'

}
