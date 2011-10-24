#!/bin/sh

bzip2 -dc snd-10.tar.bz2 |tar xv-
cd snd-10 ; patch -p1 <../changes.diff
cp new_files/* snd-10/



