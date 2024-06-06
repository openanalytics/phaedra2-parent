#!/bin/bash
# Enable the feature to stop script if any command fails
set -e

# fetch current version
current_version=`mvn -q -Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec`
echo "This is current_version: $current_version"

# Remove -SNAPSHOT from version
release_version=${current_version/-SNAPSHOT/}
echo "Release version is $release_version"

# Set release version
mvn versions:set -DnewVersion="$release_version"
# Update eu.openanalytics.phaedra dependencies with the latest release version
mvn versions:update-properties -Dincludes=eu.openanalytics.phaedra -U

## Commit and push updated pom file
git add pom.xml
git commit -m "update: set version to $release_version"
git push

# Use got flow maven plugin to release the project
mvn -B gitflow:release-start gitflow:release-finish

# Clean up, remove pom.xml.versionsBackup files created by mvn versions:set
find . -name "pom.xml.versionsBackup" -type f | xargs rm
