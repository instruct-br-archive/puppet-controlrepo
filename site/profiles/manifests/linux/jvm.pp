# Installs a JVM in the host
#
# @summary installs the OpenJDK JRE
#
# @param java_version the string version of the JVM to be installed.
# Default to '1.8.0.171-8.b10.el7_5'
#
# @example
#   include profiles::linux::jvm
#
# [Remember: No empty lines between comments and class definition]
class profiles::linux::jvm (
  String $java_version = '1.8.0.171-8.b10.el7_5',
) {

  if 'linux' == $facts['kernel'] {
    class  { 'java':
      distribution => 'jre',
      version      => $java_version,
    }
  }

}
