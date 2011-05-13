# Performs all required configuration for gridmap like security support.
# 
# == Examples
#
#   TODO:
#
# == Authors
#
# CERN IT/GT/DMS <it-dep-gt-dms@cern.ch>
#
class grid-common::gridmap {

  package { ["edg-mkgridmap"]: ensure => latest, }

  file { 
      "/etc/grid-security":
          owner  => root,
          group  => root,
          mode   => 755,
          ensure => directory;
      "/usr/share/augeas/lenses/dist/mkgridmap.aug":
          owner   => root,
          group   => root,
          mode    => 755,
          ensure  => present,
          content => template("grid-common/mkgridmap.aug");
  }

  define mkgridmap($conffile, $mapfile, $logfile) {

    file { "$name-conf":
      ensure  => present,
      path    => $conffile,
      owner   => root,
      group   => root,
      mode    => 644,
      tag     => "gridmap",
    }

    cron { "$name-cron":
      command     => $grid_flavour ? {
        "glite" => "(date; /opt/edg/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe) >> $logfile 2>&1",
        default => "(date; /usr/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe) >> $logfile 2>&1",
      },
      environment => "PATH=/sbin:/bin:/usr/sbin:/usr/bin",
      user        => root,
      hour        => [5,11,18,23],
      minute      => 55,
      require     => [
          File["$name-conf"],
          Package["edg-mkgridmap"],
      ],
    }

    exec { "$conffile-exec":
      path        => "/usr/bin:/usr/sbin:/bin:/opt/lcg/bin",
      command     => $grid_flavour ? {
        "glite" => "/opt/edg/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe",
        default => "/usr/libexec/edg-mkgridmap/edg-mkgridmap.pl --conf=$conffile --output=$mapfile --safe",
      },
      refreshonly => true,
    }
  }  

  define group($file, $voms_uri, $map) {
      augeas { "vomsgroupadd_$file-$voms_uri-$map":
          changes => [
              "set /files$file/01/type group",
              "set /files$file/01/uri $voms_uri",
              "set /files$file/01/map $map",
          ],
          onlyif => "match /files$file/*[type='group' and uri='$voms_uri'] size == 0",
          require => File[$file],
          notify  => Exec["$file-exec"],
      }
      augeas { "vomsgroupupdate_$file-$voms_uri-$map":
          changes => [
              "set /files$file/*[type='group' and uri='$voms_uri']/map $map",
          ],
          onlyif => "match /files$file/*[type='group' and uri='$voms_uri' and map!='$map'] size > 0",
          require => File[$file],
          notify  => Exec["$file-exec"],
      }
  }

  grid-common::gridmap::mkgridmap { "edg-mkgridmap":
    conffile => $grid_flavour ? {
      "glite" => "/opt/edg/etc/edg-mkgridmap.conf",
      default => "/etc/edg-mkgridmap.conf",
    },
    mapfile  => "/etc/grid-security/grid-mapfile",
    logfile  => "/var/log/edg-mkgridmap.log",
    require  => $grid_flavour ? {
      "glite" => [ File["edg_etc"], File["/etc/grid-security"] ],
      default => [ File["/etc/grid-security"] ],
    },
  }
}
