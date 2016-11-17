#!/bin/bash
tag=$1
file_path=`echo $2`
repo=$3
access_token=$4

function jsonValue() {
	KEY=$1
	num=$2
	awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}
file_name=`basename $file_path`
release_id=`curl https://api.github.com/repos/$repo/releases/tags/$tag?access_token=$access_token | jsonValue id 1`
release_id=`echo ${release_id//[[:blank:]]/}`
curl -X POST "https://uploads.github.com/repos/$repo/releases/$release_id/assets?name=$file_name&access_token=$access_token" -H "Content-Type: application/zip" --data @$file_path

echo ""