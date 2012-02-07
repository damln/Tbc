package Tbc;
use strict;
use utf8;

use Mojolicious::Lite;
use Mojo::UserAgent;

my $ua = Mojo::UserAgent->new;

sub lines {
    my $class = shift;

    my $tx = $ua->get("http://www.infotbc.com/");
    my $vals = $tx->res->dom->find('select#edit-navitia-line option:not([value=0])');

    my @lignes;

    for my $ligne ($vals->each) {
        my $ligne_hash;

        my $ligne_name = $ligne->text;
        my $ligne_id = $ligne->attrs('value');
        my @number = split('_', $ligne_id);

        $ligne_hash = {
            'id' => $ligne_id,
            'name' => $ligne_name,
            'number' => $number[1],
        };

        push(@lignes, $ligne_hash);
    }

    return [@lignes];
}

sub directions {
    my $class = shift;    # class method, so use $class
    my $line = shift;
    bless \$line, $class;
    $line = uc($line);

    my $tx = $ua->get("http://www.infotbc.com/ahah/stoppoint?navitia_line=$line");
    my $vals = $tx->res->dom->find('select option:not([value="0"])');

    my $hash;
    for my $dir ($vals->each) {
        my $route = $dir->attrs('value');
        my $name = $dir->text;
        $$hash{$route} = $name;
    };
    return $hash;
}

sub stops {
    my $class = shift;
    my $line = shift;
    bless \$line, $class;
    $line = uc($line);

    my @dirs = ('backward', 'forward');

    my $hash;
    for my $dir (@dirs) {

        my $tx = $ua->get("http://www.infotbc.com/ahah/stoppoint?navitia_line=$line&navitia_direction=$dir");
        my $vals = $tx->res->dom->find('select option:not([value="0"])');
        # Loop over stops / directions
        my @list;
        for my $i ($vals->each) {
            my $route = $i->attrs('value');
            my $name = $i->text;
            my $v = {'id'=>$route, 'name'=> $name};
            push(@list, $v);
        }

        $$hash{$dir} = [@list];
    };

    return $hash;
}

sub now {
    my $class = shift;    # class method, so use $class

    my $line_number = shift;
    my $dir = shift;
    my $stop_id = shift;

    bless \$line_number, $class;
    bless \$dir, $class;
    bless \$stop_id, $class;

    $line_number = uc($line_number);
    $stop_id = uc($stop_id);

    my $url = "http://www.infotbc.com/nextdeparture/$line_number/stoppoint/$stop_id/$dir#departure";
    my $tx = $ua->get($url);

    my @list;
    for my $tr ($tx->res->dom->find('#navitia-departure-result li')->each) {
        my $min = $tr->text;

        $min =~ s/^\s+//;
        $min =~ s/\s+$//;

        if ($min ne "")  {
            my $date = "$min";
            push(@list, $date);
        }

    }
    return [@list];

}

sub dates {
    my $class = shift;    # class method, so use $class

    my $line_number = shift;
    my $dir = shift;
    my $stop_id = shift;
    my $date = shift;

    bless \$line_number, $class;
    bless \$dir, $class;
    bless \$stop_id, $class;
    bless \$date, $class;

    $line_number = uc($line_number);
    $stop_id = uc($stop_id);

    my @cal = split('-', $date);
    my $url = "http://www.infotbc.com/timetable/$line_number/stoppoint/$stop_id/$dir/$cal[0]/$cal[1]/$cal[2]";

    my $tx = $ua->get($url);

    my @list;
    for my $tr ($tx->res->dom->find('#navitia-timetable-detail tr')->each) {
        my $hour = $tr->find('th')->first->text;

        for my $td ($tr->find('td abbr:not(.symbol-a)')->each) {
            my $min = $td->text;
            # my $via_el = $td->find('sup abbr');

            $min =~ s/^\s+//;
            $min =~ s/\s+$//;

            # if ($via_el->first) {
                # $via = "- ${$via_el->first->text}";
            # }

            if ($min ne "")  {
                my $date = "$hour$min";
                push(@list, $date);
            }
        }
    }
    return [@list];


}

1;