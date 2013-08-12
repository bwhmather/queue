#!/usr/bin/bash

function do_test
{
    reset
    chibi-scheme -s tests/tests.scm
}

do_test
while true; do
    find . -name '*.s??' -exec inotifywait -e MOVE_SELF {} +;
    do_test;
done
