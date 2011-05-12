# Installs and configures a NFS client, performing any additional required
# setup for a glite enabled NFS client.
# 
# == Examples
#
# Simply include this class, as in:
#  include grid-common::nfsclient 
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class grid-common::nfsclient {
  package { 
    "kernel-pnfs": ensure => latest;
    "nfs-utils": ensure => "1.2.3-1";
  }
}
