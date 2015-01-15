
import "base.pp"

######################################################################
# SITE SETUP

class site_setup {
  # make symlinks to the apache site config in the standard locations so
  # apache uses it.
  file { 'apache2_conf_available':
    path => '/etc/apache2/sites-available/geoRef.conf',
    ensure => link,
    target => '/home/vagrant/geocamspace/geoRef/management/apache2/geoRef.conf',
  }
  file { 'apache2_conf_enabled':
    path => '/etc/apache2/sites-enabled/geoRef.conf',
    ensure => link,
    target => '../sites-available/geoRef.conf',
    require => File['apache2_conf_available'],
  }
  # pyraptord boot script
  file { 'pyraptord_conf':
    path => '/etc/init/pyraptord.conf',
    source => '/home/vagrant/geocamspace/geoRef/management/bootscripts/pyraptord.conf',
  }

  # run 'manage.py bootstrap' to generate sourceme.sh and settings.py
  exec { 'bootstrap':
    command => '/home/vagrant/geocamspace/geoRef/management/bootstrap.py --yes genSourceme genSettings',
    creates => '/home/vagrant/geocamspace/geoRef/settings.py',
    user => 'vagrant',
  }
  # append vagrant-specific settings to base settings.py
  exec { 'extraSettings':
    command => '/bin/cat /vagrant/etc/extraSettings.py >> /home/vagrant/geocamspace/geoRef/settings.py && touch /home/vagrant/geocamspace/geoRef/build/management/extraSettings.txt',
    creates => '/home/vagrant/geocamspace/geoRef/build/management/extraSettings.txt',
    require => Exec['bootstrap'],
  }

  class dbcreate {
    mysql::db { 'geoRef':
      ensure => present,
      user => 'vagrant',
      password => 'vagrant',
      charset => 'utf8',
      collate => 'utf8_general_ci',
    }
  }
  class { 'dbcreate': }
  exec { 'dbrestore':
    command => '/bin/gunzip -c /vagrant/build/geoRef_dump.sql.gz | /home/vagrant/geocamspace/geoRef/manage.py dbshell',
    creates => '/var/lib/mysql/geoRef/auth_user.frm',
    require => [Class['dbcreate'], Exec['extraSettings']],
    user => 'vagrant',
  }
  exec { 'data_dir_unpack':
    command => '/bin/tar xfz /vagrant/build/geoRef_data_dir.tgz && chmod -R a+rX geoRef_data && chmod -R g+w geoRef_data && find geoRef_data -type d | xargs chmod g+s && chown -R www-data:www-data geoRef_data && ln -s ../geoRef_data geoRef/data',
    cwd => '/home/vagrant/geocamspace/',
    creates => '/home/vagrant/geocamspace/geoRef/data',
  }
  user { "vagrant":
    ensure => present,
    uid => 1001,
    gid => 1001,
    groups => ['www-data'],
  }
  exec { 'collectmedia':
    command => '/home/vagrant/geocamspace/geoRef/manage.py collectmedia',
    require => Exec['dbrestore'],
  }
  exec { 'prep':
    # must run as user vagrant
    command => '/bin/su -l vagrant -c "/home/vagrant/geocamspace/geoRef/manage.py prep"',
    require => Exec['collectmedia'],
  }

  # symlink shortcut
  file { '/home/vagrant/geoRef':
    ensure => link,
    target => 'geocamspace/geoRef',
  }

  # handy setup for dev work
  exec { 'bashrc_extras':
    command => '/bin/cat /vagrant/etc/bashrc_extras.sh >> /home/vagrant/.bashrc && touch /home/vagrant/.installed_bashrc_extras',
    creates => '/home/vagrant/.installed_bashrc_extras',
  }
  file { '/home/vagrant/.screenrc':
    source => '/vagrant/etc/screenrc',
  }
  file { '/home/vagrant/.emacs':
    source => '/vagrant/etc/emacs',
  }
}

class { 'site_setup':
  require => [Class['pip_packages'],
              Class['mysql_setup'],
              Class['apache_setup']],
  notify => Service['httpd'],
}
