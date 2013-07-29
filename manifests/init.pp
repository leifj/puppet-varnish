Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

include ufw

class varnish ($domain = undef,$backends = undef) {
   package {'apache2':
      ensure => "absent"
   }
   service {'apache2':
      ensure => "stopped"
   }
   package {'varnish':
      ensure => "installed"
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
      content    => template('samlbits/vcl.erb')
   }
   file {'varnish-settings':
      path       => '/etc/default/varnish',
      ensure     => file,
      require    => Package['varnish'],
      content    => template('samlbits/varnish.erb')
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
