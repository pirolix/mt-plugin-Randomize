package MT::Plugin::OMV::Randomize;

use strict;
use MIME::Base64;
use List::Util;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
$VERSION = '0.00_01';

use base qw( MT::Plugin );
my $plugin = new MT::Plugin ({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://www.magicvox.net/archive/2011/01231706/',
        description => <<HTMLHEREDOC,
<__trans phrase="Randomized sorting the items">
HTMLHEREDOC
        registry => {
            tags => {
                block => {
                    $MYNAME => \&_hdlr_randomize,
                },
                function => {
                    $MYNAME. 'Separator' => \&_hdlr_randomize_separator,
                },
            },
        },
});
MT->add_plugin ($plugin);

### Block tag - Randomize
sub _hdlr_randomize {
    my ($ctx, $args, $cond) = @_;

    my $uid = MIME::Base64::encode (pack 'C*', map { int rand 256; } 1..12 );
    $uid =~ s!^\s+|\s+$!!g;
    local $ctx->{__stash}{$MYNAME. qq{::uid}} = $uid;

    # Splitting
    my $out = $ctx->slurp ($args, $cond)
        or return; # Error
    my $separator = _hdlr_randomize_separator ($ctx);
    my @out =  split /\Q$separator\E/, $out;
    unshift @out if $out[0] !~ /\S/;
    pop @out if $out[$#out] !~ /\S/;
 
    # Output - PHP
    if (defined $args->{php}) {
        my $php = join ',', map { sprintf '\'%s\'', MT::Util::encode_php ($_, 'q'); } @out;
        my $lastn = $args->{lastn} || ($#out + 1);
        $php = <<PHPHEREDOC;
\$${MYNAME}_items = array ($php);
shuffle (\$${MYNAME}_items);
\$${MYNAME}_items = array_slice (\$${MYNAME}_items, 0, $lastn);
foreach (\$${MYNAME}_items as \$item) {
    echo \$item;
}
PHPHEREDOC
        return "<?php $php ?>" if $args->{php} == 1;
        return        $php     if $args->{php} == 2;
        return $ctx->error ("'php' argument must be 1 or 2.");
    }

    # Output - Static
    @out = List::Util::shuffle (@out);
    do { --$args->{lastn}; @out = @out[0..$args->{lastn}]; } if $args->{lastn};
    return join $args->{glue} || '', @out;
}

### Function tag - RandomizeSeparator
sub _hdlr_randomize_separator {
    my ($ctx) = @_;

    my $uid = $ctx->{__stash}{$MYNAME. qq{::uid}}
        or return $ctx->error ('I need my container.');
    sprintf '---%s---', $uid;
}

1;