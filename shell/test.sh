#!/bin/bash

declare -a Arr
Arr=(`awk '{print $0}'  num.txt`)

i=0
j=0
tmp=0
<<aabb
echo ${Arr[1]}
Arr[1]=1000
echo ${Arr[1]}
Arr[1]=${Arr[0]}
echo ${Arr[1]}
aabb
echo ${Arr[*]}

for ((i=0; i<10; i++))
do 
    for ((j=0; j<10-i-1; j++))
    do
        #echo i:$i j:$j
        if [ ${Arr[$j]} -gt ${Arr[((j+1))]} ]; then
            tmp=${Arr[$j]}
            Arr[$j]=${Arr[((j+1))]}
            Arr[((j+1))]=$tmp
            
        fi
    done
done

echo ${Arr[*]}

