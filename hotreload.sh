#!/bin/bash

while true
do
    find lib/ -name '*.dart' | entr -dnp ./hotreloader.sh /_
done
