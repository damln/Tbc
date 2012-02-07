use strict;
use utf8;

use Mojolicious::Lite;
use Mojo::DOM;
use Mojo::UserAgent;
# plugin 'TagHelpers';

use Tbc;
my $ua = Mojo::UserAgent->new;

get '/' => sub {
    my $self = shift;
    # $self->render(json => 'hello TBC');
    $self->render(template => 'index');
};

get '/lines' => sub {
    my $rep;
    my $self = shift;

    my $lines = Tbc->lines;
    $rep = { 'lines' => $lines };

    $self->render(json => $rep);
};

get '/lines/:line_id' => sub {
    my $rep;
    my $self = shift;
    my $line = $self->param('line_id');

    my $directions = Tbc->directions($line);
    my $stops = Tbc->stops($line);

    $rep = {
        'directions' => $directions,
        'stops' => $stops,
    };

    $self->render(json => $rep);
};

get '/dates/:line_number/:dir/:stop_id/now' => sub {
    my $rep;
    my $self = shift;

    my $line_number = $self->param('line_number');
    my $dir = $self->param('dir');
    my $stop_id = $self->param('stop_id');

    my $dates = Tbc->now($line_number, $dir, $stop_id);

    $rep = {
        'stop_id' => $stop_id,
        'line_number' => $line_number,
        'direction' => $dir,
        'date' => 'now',
        'dates' => $dates,
    };

    $self->render(json => $rep);
};
get '/dates/:line_number/:dir/:stop_id/:date' => sub {
    my $rep;
    my $self = shift;

    my $line_number = $self->param('line_number');
    my $dir = $self->param('dir');
    my $stop_id = $self->param('stop_id');
    my $date = $self->param('date');

    my $dates = Tbc->dates($line_number, $dir, $stop_id, $date);

    $rep = {
        'stop_id' => $stop_id,
        'line_number' => $line_number,
        'direction' => $dir,
        'date' => $date,
        'dates' => $dates,
    };

    $self->render(json => $rep);
};


app->types->type(json => 'application/json; charset=utf-8;');
app->start;