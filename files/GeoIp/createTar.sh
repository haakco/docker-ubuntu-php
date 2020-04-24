#!/usr/bin/env bash
tar -cf - *.dat *.mmdb | xz -9 --extreme -T 0 -c - > GeoIp.tar.xz
