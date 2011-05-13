# Performs all required configuration to enable a glite installation.
#
# Things like setting library paths, default paths, etc.
# 
# == Examples
#
# Simply include this class, as in:
#   include grid-common
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
import '*.pp'

class grid-common {

    package { ["lcg-CA"]: ensure => latest, }

    case $grid_flavour {
      "glite": {
        file {
          "glite":
              path   => "/opt/glite",
              owner  => root,
              group  => root,
              mode   => 755,
              ensure => directory;
          "glite_etc":
              path    => "/opt/glite/etc",
              owner   => root,
              group   => root,
              mode    => 755,
              ensure  => directory,
              require => File["glite"];
          "edg":
              path   => "/opt/edg",
              owner  => root,
              group  => root,
              mode   => 755,
              ensure => directory;
          "edg_etc":
              path    => "/opt/edg/etc",
              owner   => root,
              group   => root,
              mode    => 755,
              ensure  => directory,
              require => File["edg"];
        }
      }
    }

    file { 
        "/etc/profile.d/glite.sh":
            owner  => root,
            group  => root,
            mode   => 755,
            content => template("grid-common/glite.sh.erb"),
            ensure => present;
        "glite_ldconf":
            path    => "/etc/ld.so.conf.d/glite.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => "/opt/glite/lib64";
        "globus_ldconf":
            path    => "/etc/ld.so.conf.d/globus.conf",
            owner   => root,
            group   => root,
            mode    => 644,
            content => "/opt/globus/lib";
    }

    exec { "glite_ldconfig":
        path        => "/usr/bin:/usr/sbin:/bin:/sbin",
        command     => "ldconfig",
        subscribe   => [ File["glite_ldconf"], File["globus_ldconf"] ],
        refreshonly => true,
    }
}
