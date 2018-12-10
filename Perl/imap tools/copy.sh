#! /bin/bash

srcfolder="Professional.Pricing Tools"
dstfolder="Professional.Cisco Systems.Customer eXperience (Cisco Services).Operations and Renewals.Global Business Operations.Global Planning and Transformation.Budget Management.Sales Strategy.Pricing &- Tools.Pricing Tools"

echo "$srcfolder:$dstfolder" > map.txt
./imapcopy.pl -d -v -C -M map.txt -S 192.168.30.2/Laurent/Jrdl6468 -D 192.168.30.2/Laurent/Jrdl6468 -m "${srcfolder}"
