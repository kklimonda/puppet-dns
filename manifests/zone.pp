# Define new zone for the dns
define dns::zone (
    $zonetype       = 'master',
    $dynamic        = undef,
    $soa            = $::fqdn,
    $reverse        = false,
    $ttl            = '10800',
    $soaip          = $::ipaddress,
    $refresh        = 86400,
    $update_retry   = 3600,
    $expire         = 604800,
    $negttl         = 3600,
    $serial         = 1,
    $masters        = [],
    $allow_transfer = [],
    $zone           = $title,
    $contact        = "root.${title}.",
    $zonefilepath   = $::dns::zonefilepath,
    $filename       = "db.${title}",
) {

  validate_bool($reverse)
  validate_array($masters, $allow_transfer)

  $zonefilename = "${zonefilepath}/${filename}"

  if ($dynamic == undef) {
    $dynamic_final = $zonetype ? {
      'master' => true,
      default  => false
    }
  } else {
    $dynamic_final = $dynamic
  }

  concat::fragment { "dns_zones+10_${zone}.dns":
    target  => $::dns::publicviewpath,
    content => template('dns/named.zone.erb'),
    order   => "10-${zone}",
  }

  file { $zonefilename:
    ensure  => file,
    owner   => $dns::user,
    group   => $dns::group,
    mode    => '0644',
    content => template('dns/zone.header.erb'),
    replace => false,
    notify  => Service[$::dns::namedservicename],
  }
}
