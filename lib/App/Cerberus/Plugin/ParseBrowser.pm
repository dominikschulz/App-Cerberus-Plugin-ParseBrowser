package App::Cerberus::Plugin::ParseBrowser;

use strict;
use warnings;
use HTML::ParseBrowser;
use List::Util qw(first);
use Carp;
use parent 'App::Cerberus::Plugin';

#===================================
sub init {
#===================================
    my $self = shift;
    $self->{cache} = {};
}

#===================================
sub request {
#===================================
    my ( $self, $req, $response ) = @_;
    my $ua = $req->param('ua') or return;
    $response->{ua} = $self->{cache}{$ua} and return;

    my $detect;
    eval {
        $detect = HTML::ParseBrowser->new($ua);
    };
    return unless $detect;

    # , category, ,,
    my %data   = (
        browser   => $detect->name      || '',
        os        => $detect->os        || '',
        ostype    => $detect->ostype    || '',
        osvers    => $detect->osvers    || '',
        osarc     => $detect->osarc     || '',
        language  => $detect->language  || '',
        languages => $detect->languages || [],
        version   => {
            major => $detect->version->{'major'} || '',
            minor => $detect->version->{'minor'} || '',
            full  => $detect->v || '',
        },
        browser_properties => [ $detect->properties ],
    );

    $response->{ua} = $self->{cache}{$ua} = \%data;
}

1;

# ABSTRACT: Add user-agent information to App::Cerberus

=head1 DESCRIPTION

This plugin uses L<HTML::ParseBrowser> to add information about the user agent
to Cerberus. For instance:

    "ua": {
        "is_robot": 0,
        "vendor": "apple",
        "version": {
            "minor": ".1",
            "full": 5.1,
            "major": "5"
        },
        "browser": "safari",
        "device": "iphone",
        "os": "iOS"
    }

=method init

This method will initialize this plugin w/ an empty cache.

=method request

This method will try to detect the UA given in the ua argument.

=head1 REQUEST PARAMS

User-Agent information is returned when an User-Agent value is passed in:

    curl http://host:port/?ua=Mozilla%2F5.0 (compatible%3B Googlebot%2F2.1%3B %2Bhttp%3A%2F%2Fwww.google.com%2Fbot.html)

=head1 CONFIGURATION

This plugin takes no configuration options:

    plugins:
      - ParseBrowser

=head1 KNOWN ISSUES

When invoked after any other User-Agent plugin, this one will overwrite
the results from the other plugins. It's planned to merge the ua properties
in a later version but this is yet to be implemented.

