#!/bin/sh

# base=<absolute-path-to-source>
plsrc=analizu_revo_art.pl
goal="analizu_revo_art_prefix($1)"
#PL=/usr/bin/env swipl
PL=/usr/bin/swipl
PERL=/usr/bin/perl

cd pro
$PL -q -f "$plsrc" -g "$goal" -t halt --

cd ..
source elfiltru_trovojn.sh # -k html/ 

