#!/bin/bash

for i in {3..1}
do
	for j in {1..10..1}
	do
		./pace-csv "$j" "$i" 240
	done
done
for i in {3..1}
do
	for j in {20..100..10}
	do
		./pace-csv "$j" "$i" 240
	done
done
for i in {3..1}
do
	for j in {150..1500..50}
	do
		./pace-csv "$j" "$i" 240
	done
done