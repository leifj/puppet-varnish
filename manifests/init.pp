Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

include ufw

class varnish ($domain = undef,$backends = undef) {
   package {'apache2':
      ensure => "purged"
   }
   service {'apache2':
      ensure => "stopped"
   }
   apt::ppa { 'ppa:ondrej/varnish': }
   package {'varnish':
      ensure => "latest"
   }
   service {'varnish':
      name       => 'varnish',
      ensure     => running,
      enable     => true,
      hasrestart => true, 
      require    => Package['varnish'],
      subscribe  => [File['varnish-settings'],File['default.vcl']]
   }
   file {'default.vcl':
      path       => '/etc/varnish/default.vcl',
      ensure     => file,
      require    => Package['varnish'],
      content    => template('varnish/vcl.erb')
   }
   file {'varnish-settings':
      path       => '/etc/default/varnish',
      ensure     => file,
      require    => Package['varnish'],
      content    => template('varnish/varnish.erb')
   }
   file {'varnish-monitor':
      path       => '/etc/varnish/monitor.sh',
      ensure     => file,
      mode       => 0755,
      require    => Package['varnish'],
      content    => template('varnish/monitor.erb')
   }
   include xinetd
   xinetd::service {"varnish-monitor-server":
      port       => "8080",
      server     => '/etc/varnish/monitor.sh',
   }
   file {'varnish.vcl':
      path       => '/etc/varnish/varnish.vcl',
      ensure     => absent
   }
   ufw::allow { "allow-http":
      ip   => 'any',
      port => 80
   }
}
