# = Class: solr43
#
# This class installs/configures/manages Apache solr43. 
#
# == Parameters:
#
# $solr43_version:: the version of solr43 to install
#
# $solr43_home:: where the solr43 files will be installed
#
# $exec_path:: the path to use when executing commands on the
#             local system
#
# $number_of_cloud_shards:: specify only for solr43Cloud
#
# $zookeeper_hosts:: An comma seperated list of zookeeper hosts for solr43Cloud.
#                   Specify only for solr43Cloud
#
# == Requires:
#
# Nothing.
#
# == Sample Usage:
#
#   class {'solr::solr43':
#     number_of_cloud_shards => 2,
#     zookeeper_hosts        => ["example.com:2181", "anotherserver.org:2181/alternate_root"]
#   }
#
class solr::solr43 (
  $solr43_version = '4.3.0',
  $solr43_home = '/opt',
  $exec_path = '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin'
) {
  # using the 'creates' option here against the finished product so we only download this once
  exec { "wget solr43":
    command => "wget --output-document=/tmp/solr-${solr43_version}.tgz http://apache.petsads.us/lucene/solr/${solr43_version}/solr-${solr43_version}.tgz",
    path    => $exec_path,
    creates => "${solr43_home}/solr-${solr43_version}",
  } ->

  user { "solr43": 
    ensure => present
  } ->

  exec { "untar solr43":
    command => "tar -xf /tmp/solr-${solr43_version}.tgz -C ${solr43_home}",
    path    => $exec_path,
    creates => "${solr43_home}/solr-${solr43_version}",
  } ->

  file { "${solr43_home}/solr43":
    ensure => link,
    target => "${solr43_home}/solr-${solr43_version}/",
    owner  => solr43,
  } ->

  file { "/etc/solr43":
    ensure => directory,
    owner  => solr43,
  } ->

  file { "/var/log/solr43":
    ensure => directory,
    owner  => solr43,
  } ->


  file { "/etc/solr43/solr.xml":
    ensure => present,
    source => "puppet:///modules/solr/solr43.xml",
    owner  => solr43,
  } ->
  
  file { "/var/lib/solr43":
    ensure => directory,
    owner  => solr43,
  } -> 

  file { "/etc/init.d/solr43":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/solr43"
  } ->

  file { "/opt/solr43/example/logging.properties":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/logging.properties43"
  } ->

  file { "/opt/solr43/example/lib/ext/slf4j-log4j12-1.6.6.jar":
    ensure => "absent",
  } ->

  file { "/opt/solr43/example/lib/ext/jul-to-slf4j-1.6.6.jar":
    ensure => "absent",
  } ->

  file { "/opt/solr43/example/lib/ext/slf4j-log4j-1.2.16.jar":
    ensure => "absent",
  } ->

  file { "/opt/solr43/example/lib/ext/log4j-over-slf4j-1.6.6.jar":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/log4j-over-slf4j-1.6.6.jar"
  } ->

  file { "/opt/solr43/example/lib/ext/slf4j-jdk14-1.6.6.jar":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/slf4j-jdk14-1.6.6.jar"
  } ->

  file { "/etc/default/solr43-jetty":
    content => template("solr/solr43-jetty.erb"),
    ensure => present,
    owner  => solr43,
  } ->

  exec { "start-solr43":
    command => "/etc/init.d/solr43 start",
    path    => $exec_path,
    unless => "ps aux | grep solr43 | grep -v grep",
  }

}
