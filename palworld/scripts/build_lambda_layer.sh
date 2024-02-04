#!/bin/bash

mkdir -p python
pip install requests -t python/
zip -r requests_layer.zip python
rm -rf python

