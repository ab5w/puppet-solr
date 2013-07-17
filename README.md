puppet-solr
===========

Puppet module for installing solr with a stand alone jetty server.
 
This module has been changed to allow two versions (4.3.0 and 3.6.0) to run on the same servers and listening on different ports.

To use you would include the following into your site.pp;

	class { 'solr::solr36': }

	class { 'solr::solr43': }

You can set the version required in each of the solr*.pp files in manifests, however be aware that solr36.pp pulls the download from the archive site.

