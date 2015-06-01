#!/bin/bash

set -e # exit with nonzero exit code if anything fails

# we're using Travis's before_script config instaed of doing the (now commented) check-then-install logic below:

#asciidoctor_installed=$(gem list -i asciidoctor)
#pygments_installed=$(gem list -i pygments)

#if [ ! $asciidoctor_installed ]; then
#    printf '%s\n' "Installing asciidoctor"
#    gem install asciidoctor
#    printf '%s\n' "Installed asciidoctor"
#fi

#if [ ! $pygments_installed ]; then
#    printf '%s\n' "Installing pygments"
#    gem install pygments.rb
#    printf '%s\n' "Installed pygments"
#fi

# build time in UTC (ISO 8601 format):
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

asciidoctor --safe -a revdate="${NOW}" -D build draft-ion.adoc
