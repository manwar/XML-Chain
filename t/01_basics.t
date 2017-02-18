#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use open ':std', ':encoding(utf8)';
use Test::Most;

use FindBin qw($Bin);
use lib "$Bin/lib";

use XML::Chain qw(xc);

subtest 'xc()' => sub {
    my $body = xc('body');
    isa_ok($body, 'XML::Chain::Selector', 'xc(exported) returns selector');
    isa_ok($body->xc, 'XML::Chain', 'xc(exported)->xc is a reference to the parent');
    is($body->as_string, '<body/>', 'create an element');

    cmp_ok($body->as_string, 'eq', $body->toString, 'toString alias to as_string');

    my $h1 = $body->c('h1')->t('I am heading');
    isa_ok($h1,'XML::Chain::Selector','$h1 → selector on traversal');
    is($body->as_string, '<body><h1>I am heading</h1></body>', 'selector create an element');
};

subtest 'basic creation' => sub {
    my $div = xc('div', class => 'pretty')
                ->c('h1')->t('hello')
                ->up
                ->c('p', class => 'intro')->t('world!')
                ->root;
    is($div->as_string, '<div class="pretty"><h1>hello</h1><p class="intro">world!</p></div>', '=head1 SYNOPSIS; block1 -> chained create elements');

    my $icon_el = xc('i', class => 'icon-download icon-white');
    is($icon_el->as_string, '<i class="icon-download icon-white"/>', '=head2 xc; sample');

    my $span_el = xc('span')->t('some')->t(' ')->t('more text');
    is($span_el->as_string, '<span>some more text</span>', '=head2 t; sample');

    my $over_el = xc('overload');
    is("$over_el", '<overload/>', '=head2 as_string; sample');

    my $head2_root = xc('p')
        ->t('this ')
        ->c('b')
            ->t('is')->up
        ->t(' important!')
        ->root->as_string;
    is($head2_root, '<p>this <b>is</b> important!</p>', '=head2 root; sample');

    return;
};

subtest 'navigation' => sub {
    my $body = xc('body')
                ->c('p')->t('para1')->up
                ->c('p')
                    ->t('para2 ')
                    ->c('b')->t('important')->up
                    ->t(' para2_2 ')
                    ->c('b', class => 'less')->t('less important')->up
                    ->t(' para2_3')
                    ->up
                ->c('p')->t('the last one')
                ->root;
    is($body->as_string, '<body><p>para1</p><p>para2 <b>important</b> para2_2 <b class="less">less important</b> para2_3</p><p>the last one</p></body>', 'test test xml');
    my ($para_el) = $body->children->first->as_xml_libxml;
    isa_ok($para_el, 'XML::LibXML::Element', 'first <p>');

    is($body->root->find('//b')->count, 2, 'two <b> tags');
    is($body->root->find('//p/b[@class="less"]')->text_content, 'less important', q{find('//p/b[@class="less"]')});
    is($body->root->find('/body/p[position() = last()]')->text_content, 'the last one', q{find('/body/p[position() = last()]')});
};


done_testing;
