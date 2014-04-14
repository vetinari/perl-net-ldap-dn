# NAME

Net::LDAP::DN - Handling of LDAP distinguished names

# SYNOPSIS

    use Net::LDAP::DN;
    use Net::LDAP::Entry;

    my $user      = Net::LDAP::DN->
                       new('UID=username,OU=users,DC=example,DC=org');
    my $someone   = Net::LDAP::DN->
                       new('UID=someone,OU=users,DC=example,DC=org');
    my $user_base = Net::LDAP::DN->new('OU=users,DC=example,DC=org');
    my $base      = Net::LDAP::DN->new('DC=example,DC=org');
    my $disabled  = Net::LDAP::DN->new('OU=disabled,DC=example,DC=org');

    if ($user->parent eq $user_base) {
      # ... do something;
    }
    if ($user->is_subordinate($base)) {
      # ...
    }
    my $common = $user & $someone;
    print "common parent is $common\n";

    my $moved = $user->clone->move($disabled);
    my $entry = Net::LDAP::Entry->new("$user");
    $entry->changetype('moddn');
    $entry->add(
               newrdn => $moved->rdn(1),
               newsuperior => $moved->parent->as_string, # or "$disabled"
               deleteoldrdn => 1,
           )->update( $conn );

    print for sort { $b cmp $a } (($user, $someone, $user_base, $base, $disabled));

# DESCRIPTION

The __Net::LDAP::DN__ object represents a single distinguished name. It is used
to compare DNs and do some basic operations like finding if they share a common
parent.

This module is a wrapper around [Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util)'s _ldap\_explode\_dn_ and
_canonical\_dn_.

This module does not update the LDAP server, it just operates on DNs and
helps you with setting up arguments for e.g. [Net::LDAP::Entry](http://search.cpan.org/perldoc?Net::LDAP::Entry).

For convenience some methods are overloaded via the [overload](http://search.cpan.org/perldoc?overload) class:

- ""

$dn->as\_string()

- cmp

$dn->compare(OTHER)

- eq

$dn->equal(OTHER)

- ne

not $dn->equal(OTHER)

- lt

$dn->is\_subordinate(OTHER)

- gt

OTHER->is\_subordinate($dn)

- le

Like expected `lt or eq`.

- ge

Like expected `gt or eq`.

- &

$dn->common\_base(OTHER)

- \-

$dn->strip(OTHER)

- \+

$dn->append(OTHER)

# CONSTRUCTORS

- new ( )

Create a new object. Optionally you can provide a DN as a string or an
array ref like [Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util)'s _ldap\_explode\_dn_ and a pair of
options like _ldap\_explode\_dn_ / _canonical\_dn_ support them. One extra
option `case_insensitive` may be given to compare the RDN values case
insensitive.

    Net::LDAP::DN->new()

    # or
    Net::LDAP::DN->new('uid=someone,dc=example,dc=org');

    # or
    Net::LDAP::DN->new('uid=someone,dc=example,dc=org', casefold => 'lower');

- clone ( \[DN\] )

Returns a copy of the __Net::LDAP::DN__ object, optionally set a new DN
as well.

# METHODS

- options ( )

Returns or sets the options which are passed to the underlying functions
from [Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util).

- case\_insensitive ( )

Get or set if the values should be compared case insensitive.

- dn ( )

Returns or sets the DN as array ref like [Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util)'s
_ldap\_explode\_dn_ returns it.

- as\_string ( )

Returns the DN as string - wrapper for [Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util)'s _canonical\_dn_,
options passed are the ones you gave earlier.

- parent ( )

Returns the direct parent of the DN as new __Net::LDAP::DN__ object.

- rdn ( )

Returns the first RDN of the DN, when passed a true value as argument, this
includes the attribute.

NOTE: when no or a false value is passed the values of a multivalued RDN
are joined by `+`.

To get the RDN as a new __Net::LDAP::DN__ object use

    my $rdn = $user->clone;
    $rdn = $clone->dn($user->dn->[0]);

- attr ( )

Returns the attribute of the RDN.

The attributes of a multivalued RDN are joined by `+`.

- attributes ( )

Returns all attributes of the DN

- values ( )

Returns all values of the DN

- append ( DN )

Returns a new object with the given DN appended, also available with
the overloaded `+` operator:

    my $moved = ( $user_dn - $user_dn->parent ) + $new_base;

- strip ( DN )

Returns a new object with the given DN stripped, see above in ["append"](#append)
for usage with the overloaded `-` operator.

- pretty ( SEP, \[FUNC\] )

Returns a `pretty` name of the DN in reverse order, intended usage is like

    my $adm = Net::LDAP::DN->new('cn=admin,ou=groups,ou=myapp,dc=example,dc=org');
    my $base = Net::LDAP::DN->new('DC=example,DC=org');
    print $adm->strip($base)->pretty("/", sub { ucfirst shift }), "\n";
    # prints "Myapp/Groups/Admin\n"

Default separator SEP is a `/`.

FUNC is a code ref which is called for each element before joining, the
default is `sub { $_[0]; }`, i.e. a no-op.

- common\_base ( OTHER )

Returns the common base which the object and OTHER share.

- equal ( OTHER )

Returns true if the object's DN and OTHER's DN are equal.

- compare ( OTHER )

Returns `-1` if the object is a subordinate of OTHER, `1` if OTHER is a
subordinate of the object, otherwise `0`.

- is\_subordinate ( OTHER )

Returns true when OTHER is a parent of the object (not necessarily a direct
parent), i.e. `uid=user,ou=users,dc=example,dc=org` is a subordinate of
`dc=example,dc=org`.

- rename ( NEWRDN )

Renames RDN to NEWRDN. NEWRDN must be a hashref like

    { uid => "user" }

or two arguments like

    $user->rename(cn => "New Name");

Note: to move and rename, just combine with ["move"](#move):

    $user->rename(cn => "New Name")->move($new_base);

- move ( BASE )

Moves RDN to the new base BASE.

# EXAMPLES

    use Net::LDAP::DN;
    $dn   = Net::LDAP::DN->new("uid=foo", casefold => "lower");
    $base = Net::LDAP::DN->new("dc=example,dc=org");
    $ppl  = [ { OU => "people" }, { ou => "users" } ];
    $spec = { ou=>"special" };
    $adm  = "OU=admin";
    print $dn + $adm + $spec + $ppl + $base,"\n";
    # uid=foo,ou=admin,ou=special,ou=people,ou=users,dc=example,dc=org

# SEE ALSO

[Net::LDAP](http://search.cpan.org/perldoc?Net::LDAP),
[Net::LDAP::Util](http://search.cpan.org/perldoc?Net::LDAP::Util),
[Net::LDAP::Entry](http://search.cpan.org/perldoc?Net::LDAP::Entry),

# AUTHOR

Hanno Hecker <vetinari@ankh-morp.org>.

# COPYRIGHT

Copyright (c) 2014 Hanno Hecker. All rights reserved. This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.
