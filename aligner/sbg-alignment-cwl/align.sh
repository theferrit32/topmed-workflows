#!/bin/bash

ref_path=$1
input_path=$2
list=$3

line=$(grep $(basename $input_path) < $list)

line_rg=$(echo $line | cut -d \' \' -f 4- | sed -e \"s\/ \/\\\\\\t\/g\")
input_filename=$(basename $input_path)
output_filename=$(basename $input_filename \".fastq.gz\").cram

paired_flag=\"\"
if [[ $input_filename =~ interleaved\\.fastq\\.gz$ ]]
then
  paired_flag=\"-p\"
fi

bwa mem -t 32 -K 100000000 -Y ${paired_flag} -R \"$line_rg\" $ref_path $input_path | samblaster -a --addMateTags | samtools view -@ 32 -T $ref_path -C -o $output_filename -
