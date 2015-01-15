
# force a one-time 'apt-get update' before installing any packages.
# otherwise apt-get may hit the wrong servers and error out.
exec { 'apt_update':
  command => '/usr/bin/apt-get update && touch /home/vagrant/.apt-updated',
  creates => '/home/vagrant/.apt-updated',
}
Exec['apt_update'] -> Package <| |>

class ubuntu_packages {
  # put extra packages to install here. see base.pp in xgds_base_vagrant
  # for a list of packages already installed.

  # for rendering icons -- could probably remove need for this
  package { 'imagemagick': }

  # optional - includes useful 'reindent.py' script for dev
  package { 'python-examples': }

  # optional - provides useful 'ack' command for dev
  package { 'ack-grep': }
  file { '/usr/bin/ack':
    ensure => link,
    target => '/usr/bin/ack-grep',
    require => Package['ack-grep'],
  }

  # optional - needed for pykml
  package { 'python-lxml': }
}

class { 'ubuntu_packages': }

class pip_packages {
  # put extra packages to install here. see base.pp in xgds_base_vagrant
  # for a list of packages already installed.

  package { 'tornado':
    provider => 'pip',
  }
  package { 'fpdf':
    provider => 'pip',
  }
  package { 'qrcode':
    provider => 'pip',
  }
  package { 'django-tagging':
    provider => 'pip',
  }
  package { 'rdflib':
    provider => 'pip',
    ensure => '2.4.2',
  }
  package { 'slimit':
    provider => 'pip',
  }

  # optional - needed for manage.py lint
  package { 'pylint':
    provider => 'pip',
  }
  package { 'pep8':
    provider => 'pip',
  }
  # this doesn't work as expected; replaced with exec resource below
  #package { 'closure-linter':
  #  source => 'http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz',
  #  provider => 'pip',
  #}
  exec { 'closure-linter':
     command => '/usr/bin/pip install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz && touch /home/vagrant/.installed-closure-linter',
     creates => '/home/vagrant/.installed-closure-linter',
  }

  # optional - for kml validation during testing
  package { 'pykml':
    provider => 'pip',
    require => Package['python-lxml'],
  }

  # optional - improves manage.py test
  package { 'django-discover-runner':
    provider => 'pip',
  }

}
class { 'pip_packages': }
Class['ubuntu_packages'] -> Class['pip_packages']

class mysql_setup {
  # https://forge.puppetlabs.com/puppetlabs/mysql

  anchor { 'mysql_setup::begin':
    before => [Class['mysql::server'],
               Class['mysql::bindings::python']],
  }

  # install mysqld server
  class { 'mysql::server':
    config_hash => {
      'root_password' => 'vagrant',
    },
  }
  # install python bindings
  class { 'mysql::bindings::python': }
  # create database
  anchor { 'mysql_setup::end':
    require => [Class['mysql::server'],
                Class['mysql::bindings::python']],
  }
}
class { 'mysql_setup': }

class apache_setup {
  # https://forge.puppetlabs.com/puppetlabs/apache

  anchor { 'apache_setup::begin':
    before => [Class['apache'],
               Class['apache::mod::wsgi'],
               ]
  }
  class { 'apache':
    default_vhost => false,
  }
  apache::listen { '80': }
  apache::mod { 'rewrite': }
  class { 'apache::mod::wsgi': }
  anchor { 'apache_setup::end':
    require => [Class['apache'],
                Class['apache::mod::wsgi']],
  }
}
class { 'apache_setup': }
