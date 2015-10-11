package Bencher::Scenario::TextTableModules;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

sub _make_table {
    my ($cols, $rows) = @_;
    my $res = [];
    push @$res, [];
    for (0..$cols-1) { $res->[0][$_] = "col" . ($_+1) }
    for my $row (1..$rows) {
        push @$res, [ map { "row$row.$_" } 1..$cols ];
    }
    $res;
}

our $scenario = {

    participants => [
        {
            module => 'Text::ANSITable',
            code => sub {
                my ($table) = @_;
                my $t = Text::ANSITable->new(
                    use_utf8 => 0,
                    use_box_chars => 0,
                    use_color => 0,
                    columns => $table->[0],
                    border_style => 'Default::single_ascii',
                );
                $t->add_row($table->[$_]) for 1..@$table-1;
                $t->draw;
            },
        },
        {
            module => 'Text::ASCIITable',
            code => sub {
                my ($table) = @_;
                my $t = Text::ASCIITable->new();
                $t->setCols(@{ $table->[0] });
                $t->addRow(@{ $table->[$_] }) for 1..@$table-1;
                "$t";
            },
        },
        {
            module => 'Text::FormatTable',
            code => sub {
                my ($table) = @_;
                my $t = Text::FormatTable->new(join('|', ('l') x @{ $table->[0] }));
                $t->head(@{ $table->[0] });
                $t->row(@{ $table->[$_] }) for 1..@$table-1;
                $t->render;
            },
        },
        {
            module => 'Text::MarkdownTable',
            code => sub {
                my ($table) = @_;
                my $out = "";
                my $t = Text::MarkdownTable->new(file => \$out);
                my $fields = $table->[0];
                foreach (1..@$table-1) {
                    my $row = $table->[$_];
                    $t->add( {
                        map { $fields->[$_] => $row->[$_] } 0..@$fields-1
                    });
                }
                $t->done;
                $out;
            },
        },
        {
            module => 'Text::Table',
            code => sub {
                my ($table) = @_;
                my $t = Text::Table->new(@{ $table->[0] });
                $t->load(@{ $table }[1..@$table-1]);
                $t;
            },
        },
        {
            module => 'Text::Table::Tiny',
            code => sub {
                my ($table) = @_;
                Text::Table::Tiny::table(rows=>$table, header_row=>1);
            },
        },
        {
            module => 'Text::TabularDisplay',
            code => sub {
                my ($table) = @_;
                my $t = Text::TabularDisplay->new(@{ $table->[0] });
                $t->add(@{ $table->[$_] }) for 1..@$table-1;
                $t->render; # doesn't add newline
            },
        },
    ],

    datasets => [
        {name=>'0tiny(1x1)'    , args => [_make_table( 1, 1)],},
        {name=>'1small(3x5)'   , args => [_make_table( 3, 5)],},
        {name=>'2wide(30x5)'   , args => [_make_table(30, 5)],},
        {name=>'3long(3x300)'  , args => [_make_table( 3, 300)],},
        {name=>'4large(30x300)', args => [_make_table(30, 300)],},
    ],

};

1;
# ABSTRACT: Benchmark Perl text table modules

=head1 SYNOPSIS

 % bencher -m TextTableModules [other options]...
