exec { 'apt-update':
  command => '/usr/bin/sudo /usr/bin/apt-get update',
  before  => [Package['slapd'], Package['ldap-utils'] ]

}
package {'slapd':
  ensure  => present,
  require => Exec['apt-update']
}

package { 'ldap-utils':
  ensure  => present,
  require => Exec['apt-update']
}

file { '/etc/ldap/slapd.d':
  ensure  => absent,
  recurse => true,
  purge   => true,
  force   => true,
  require => [Package['slapd'], Package['ldap-utils'] ]
}

file { '/var/lib/ldap':
  ensure  => directory,
  owner   => 'openldap',
  group   => 'openldap',
  mode    => '0644',
  require => [Package['slapd'], Package['ldap-utils'] ]

}

file { '/etc/ldap/slapd.conf':,
  owner   => 'openldap',
  group   => 'openldap',
  mode    => '0644',
  source  => '/vagrant_files/slapd.conf',
  require => [Package['slapd'], Package['ldap-utils'] ],
  notify => Service['slapd']

}
service { 'slapd':
  ensure => running
}

exec { 'add schema':
  path    => ['/usr/sbin','/usr/bin'],
  command => 'sudo service slapd stop; sudo slapadd -l /vagrant_files/ldap-premade.ldif; sudo service slapd start',
  require => [Package['slapd'], Package['ldap-utils'], Service['slapd'] ]
}


exec { 'Set the password':
  path    => ['/usr/sbin','/usr/bin'],
  command => 'ldappasswd -x -w secret -D cn=admin,dc=openmrs,dc=org -s secret \
  uid=omrsid,ou=system,dc=openmrs,dc=org',
  require => [Package['slapd'], Package['ldap-utils'], Service['slapd'], Exec["add schema"]]
}
