# = Class: solr36
#
# This class installs/configures/manages Apache solr36. 
#
# == Parameters:
#
# $solr36_version:: the version of solr36 to install
#
# $solr36_home:: where the solr36 files will be installed
#
# $exec_path:: the path to use when executing commands on the
#             local system
#
# $number_of_cloud_shards:: specify only for solr36Cloud
#
# $zookeeper_hosts:: An comma seperated list of zookeeper hosts for solr36Cloud.
#                   Specify only for solr36Cloud
#
# == Requires:
#
# Nothing.
#
# == Sample Usage:
#
#   class {'solr::solr36':
#     number_of_cloud_shards => 2,
#     zookeeper_hosts        => ["example.com:2181", "anotherserver.org:2181/alternate_root"]
#   }
#
class solr::solr36 (
  $solr36_version = '3.6.0',
  $solr36_home = '/opt',
  $exec_path = '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin'
) {
  # using the 'creates' option here against the finished product so we only download this once
  exec { "wget solr36":
    command => "wget --output-document=/tmp/solr-${solr36_version}.tgz http://archive.apache.org/dist/lucene/solr/${solr36_version}/apache-solr-${solr36_version}.tgz",
    path    => $exec_path,
    creates => "${solr36_home}/apache-solr-${solr36_version}",
  } ->

  user { "solr36": 
    ensure => present
  } ->

  exec { "untar solr36":
    command => "tar -xf /tmp/solr-${solr36_version}.tgz -C ${solr36_home}",
    path    => $exec_path,
    creates => "${solr36_home}/apache-solr-${solr36_version}",
  } ->

  file { "${solr36_home}/solr36":
    ensure => link,
    target => "${solr36_home}/apache-solr-${solr36_version}",
    owner  => solr36,
  } ->

  file { "/etc/solr36":
    ensure => directory,
    owner  => solr36,
  } ->

  file { "/var/log/solr36":
    ensure => directory,
    owner  => solr36,
  } ->


  file { "/etc/solr36/solr.xml":
    ensure => present,
    source => "puppet:///modules/solr/solr36.xml",
    owner  => solr36,
  } ->
  

  file { "/var/lib/solr36":
    ensure => directory,
    owner  => solr36,
  } -> 

  file { "/etc/init.d/solr36":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/solr36"
  } ->

  file { "/opt/solr36/example/logging.properties":
    ensure => "present",
    mode   => '0755',
    source => "puppet:///modules/solr/logging.properties36"
  } ->

  file { "/etc/default/solr36-jetty":
    content => template("solr/solr36-jetty.erb"),
    ensure => present,
    owner  => solr36,
  } ->

  exec { "start-solr36":
    command => "/etc/init.d/solr36 start",
    path    => $exec_path,
    unless => "ps aux | grep solr36 | grep -v grep",
  }


}
