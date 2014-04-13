# -*- perl -*-

use inc::Module::Install;

perl_version    5.008001;

name        'perl-net-ldap-dn';
module_name 'Net::LDAP::DN';
abstract    'LDAP distinguieshed names';
version_from    'lib/Net/LDAP/DN.pm';
author      'Hanno Hecker <vetinari@ankh-morp.org>';
license     'perl';

resources
    repository  => 'https://github.com/vetinari/perl-net-ldap-dn',
    ;

check_nmake;   # check and download nmake.exe for Win32

test_requires▸  'Test::More';
test_requires▸  'File::Basename';
test_requires▸  'File::Compare';
test_requires▸  'File::Path';


auto_install_now;

WriteAll   sign => 1;
