#!/bin/bash
echo "Enter your source Artifactory URL: "
read Source_ART_URL
SOURCE_ART=${Source_ART_URL%/}
echo "Enter your source repository name: "
read Source_repo_name
echo "Enter admin username for source Artifactory: "
read source_username
echo "Password for source Artifactory: "
read -s source_password

echo $Source_repo_name
echo $SOURCE_ART

curl -X POST -u$source_username:$source_password $SOURCE_ART/api/search/aql -d 'items.find({"$and": [{"repo" : "$Source_repo_name"}, {"name" : {"$match" : "*.marker"}}]})' -H "Content-Type: text/plain" > marker_layers.txt

jq -M -r '.results[] | "\(.path)/blobs/\(.name)"' marker_layers.txt > marker_paths.txt

sed 's/[",]//g' marker_paths.txt | sed 's|library/||g' | sed 's/.marker//g' | sed "s/__/:/g" > download_markers.txt

while read p; do


prefix=$SOURCE_ART/api/docker/$Source_repo_name/v2/$p
#awk -v prefix="$prefix" '{print prefix $0}' docker_uri.txt > filepaths_uri.txt

curl -u$source_username:$source_password $prefix > /dev/null
#cat filepaths_uri.txt | xargs -n 1 curl -sS -L -u$source_username:$source_password > /dev/null
#rm source.log docker_uri.txt filepaths_uri.txt
done <download_markers.txt