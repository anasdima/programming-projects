#!/bin/bash

for i in {3..1}
do
	for j in {50..20000..50}
	do
		./pace-csv "$j" "$i" 20
	done
done
for i in {3..1}
do
	for j in {25000..100000..5000}
	do
		./pace-csv "$j" "$i" 20
	done
done
for i in {3..1}
do
	for j in {150000..1000000..50000}
	do
		./pace-csv "$j" "$i" 20
	done
done
