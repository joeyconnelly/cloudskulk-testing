#!/bin/bash

version="lmbench-3.0-a9"
download="lmbench-3.0-a9.tgz"

tar -xvzf $download -C $HOME
cd $version/src

make results

