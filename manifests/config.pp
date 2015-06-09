# Configure dns
class dns::config(
  $options_hash = {},
  $owner = $::dns::params::user,
  $group = $::dns::params::group,
  $perms = "0640",
){
  group { $dns::params::group: }

  concat { $::dns::publicviewpath:
    owner => root,
    group => $dns::params::group,
    mode  => '0640',
  }
  concat::fragment { 'dns_zones+01-header.dns':
    target  => $::dns::publicviewpath,
    content => ' ',
    order   => '01',
  }

  file {
    $dns::namedconf_path:
      owner   => root,
      group   => $dns::params::group,
      mode    => '0640',
      content => template('dns/named.conf.erb');
    $dns::optionspath:
      owner   => root,
      group   => $dns::params::group,
      mode    => '0640',
      content => template('dns/options.conf.erb');
    $dns::zonefilepath:
      ensure  => directory,
      owner   => $owner,
      group   => $group,
      mode    => $perms;
  }

  exec { 'create-rndc.key':
    command => "/usr/sbin/rndc-confgen -r /dev/urandom -a -c ${dns::rndckeypath}",
    creates => $dns::rndckeypath,
  } ->
  file { $dns::rndckeypath:
    owner => 'root',
    group => $dns::params::group,
    mode  => '0640',
  }
}

