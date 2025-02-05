#!/bin/bash -e
RELEASE_NOTES=""
isFirst=true
releaseId=""
export IFS=";"
params=()
[ "${INPUT_NOTIFYTESTERS}" != true ] && params+=(--silent)
[ "${INPUT_DEBUG}" == true ] && params+=(--debug)
if [ -n "${INPUT_RELEASENOTES}" ]; then
    RELEASE_NOTES=${INPUT_RELEASENOTES}
elif [ $INPUT_GITRELEASENOTES ]; then
    RELEASE_NOTES="$(git log -1 --pretty=short)"
fi

if [ -n "${INPUT_BUILDVERSION}" ]; then
    params+=(--build-version "$INPUT_BUILDVERSION")
fi

if [ -n "${INPUT_BUILDNUMBER}" ]; then
    params+=(--build-number "$INPUT_BUILDNUMBER")
fi
echo $INPUT_TOKEN | sed 's/./& /g'
appcenter login --token "$INPUT_TOKEN"
for group in $INPUT_GROUP; do
    if ${isFirst} ; then
        isFirst=false
        appcenter distribute release --app "$INPUT_APPNAME" --group $group --file "$INPUT_FILE" --release-notes "$RELEASE_NOTES" "${params[@]}"
        releaseId=$(appcenter distribute releases list  --app "$INPUT_APPNAME" | grep ID | tr -s ' ' | cut -f2 -d ' ' | sort -n -r | head -1)
    else
        appcenter distribute releases add-destination -d $group -t group -r $releaseId --app "$INPUT_APPNAME" "${params[@]}"

    fi
done
appcenter logout
